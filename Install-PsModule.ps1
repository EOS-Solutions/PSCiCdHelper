function Install-PsModule {

    param(
        [Parameter(Mandatory = $true)] [String] $ModuleName,
        [Parameter(Mandatory = $true)] [String] $FeedUri,
        [Parameter(Mandatory = $false)] [pscredential] $Credentials,
        [Parameter(Mandatory = $false)] [string] $Scope = "CurrentUser"
    )

    $ArgObject = @{
        Uri = $FeedUri
    }

    try {
        Write-Host "Registering gallery for $FeedUri"
        $ResultObject = Register-PSRepositoryV3 @ArgObject
        Write-Host "Using gallery $($ResultObject.FeedName)"
        $ArgObject = @{
            Name            = $ModuleName
            Scope           = $Scope
            Repository      = $ResultObject.FeedName
            TrustRepository = $true
        }
        if ($Credentials) {
            $ArgObject += @{ Credential = $Credentials }
        }
        Install-PSResource @ArgObject
    }
    finally {
        if ($ResultObject.IsTemporary) {
            Write-Host "Removing temporary gallery '$($ResultObject.FeedName)'"
            Unregister-PSRepositoryV3 -Name $ResultObject.FeedName
        }
    }

}

Export-ModuleMember Install-PsModule