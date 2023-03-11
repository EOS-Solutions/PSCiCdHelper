function Initialize-NuGetFeed {

    param(
        [Parameter(Mandatory = $false)]
        [String] $NugetConfigFilename,

        [Parameter(Mandatory = $true)]
        [String] $PackageFeedUrl,
        
        [Parameter(Mandatory = $false)]
        [pscredential] $PackageFeedCredentials,

        [Parameter()]
        [switch] $StorePasswordsInClearText
    )

    ##debug
    $StorePasswordsInClearText = $true

    $FromNugetConfigFilename = $NugetConfigFilename
    if (-not $FromNugetConfigFilename) {
        $FromNugetConfigFilename = "$env:AppData\NuGet\nuget.config"
    }
    Write-Host "Using configuration from '$FromNugetConfigFilename'"

    $doc = [System.Xml.XmlDocument]::new()
    $doc.Load($FromNugetConfigFilename)
    $doc.SelectNodes("configuration/packageSources/add") | Where-Object {
        $Url = $_.Attributes["value"].Value.ToLowerInvariant()
        return $Url.StartsWith($PackageFeedUrl.ToLowerInvariant())
    } | ForEach-Object {
        $FeedName = $_.Attributes["key"].Value
        Write-Host "Removing feed '$FeedName'"
        $dotNetArgs = @(
            "nuget", "remove", "source", $feedName
        )
        if ($NugetConfigFilename) {
            $dotNetArgs += @( "--configfile", $NugetConfigFilename )
        }
        & dotnet @dotNetArgs
    }

    # we're on devops here, so register a feed with credentials
    $FeedName = "$([Guid]::NewGuid())".Substring(0, 8)
    Write-Host "Registering NuGet credentials on temporary feed '$FeedName'"
    $dotNetArgs = @(
        "nuget", "add", "source", $PackageFeedUrl,
        "--name", $FeedName
    )
    if ($NugetConfigFilename) {
        $dotNetArgs += @( "--configfile", $NugetConfigFilename )
    }
    if ($PackageFeedCredentials) {
        $nc = $PackageFeedCredentials.GetNetworkCredential()
        $dotNetArgs += @(
            "--username", $nc.UserName,
            "--password", $nc.Password
        )
        if ($StorePasswordsInClearText) {
            $dotNetArgs += @( "--store-password-in-clear-text" )
        }
    }
    & dotnet @dotNetArgs | Out-Null

    Write-Output $FeedName

}
Export-ModuleMember Initialize-NuGetFeed