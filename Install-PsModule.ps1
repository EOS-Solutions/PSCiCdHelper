function Install-PsModule {

    param(
        [Parameter(Mandatory = $true)] [String] $ModuleName,
        [Parameter(Mandatory = $true)] [String] $FeedUri,
        [Parameter(Mandatory = $false)] [pscredential] $Credentials
    )

    $ArgObject = @{
        Uri = $FeedUri
    }
    if ($Credentials) {
        Write-Host "Using password authentication: $($Credentials.Username)"
        $ArgObject += @{
            Credentials = $Credential
        }
    }

    try {
        Write-Host "Registering gallery for $FeedUri"
        $ResultObject = Register-PSRepositoryWithSource @ArgObject
        Write-Host "Using gallery $($ResultObject.FeedName)"
        $ArgObject = @{
            Name       = $ModuleName
            Repository = $ResultObject.FeedName
        }
        if ($Credentials) {
            $ArgObject += @{ Credential = $Credentials }
        }
        Install-PSResource @ArgObject
    }
    finally {
        if ($ResultObject.IsTemporary) {
            Write-Host "Removing temporary gallery '$($ResultObject.FeedName)'"
            Unregister-PSRepositoryWithSource -Name $ResultObject.FeedName
        }
    }

}

Export-ModuleMember Install-PsModule