function Import-PsModule {

    param(
        [Parameter(Mandatory = $true)] [String] $ModuleName,
        [Parameter(Mandatory = $true)] [String] $FeedUri,
        [Parameter(Mandatory = $false)] [pscredential] $Credentials,
        [Parameter(Mandatory = $false)] [switch] $EnsureLatest,
        [Parameter(Mandatory = $false)] [Version] $MinimumVersion = $null,
        [Parameter(Mandatory = $false)] [switch] $Global,
        [Parameter(Mandatory = $false)] [string] $Scope = "CurrentUser"
    )

    try {
        $AvailableModules = Get-InstalledPSResource -Scope $Scope $ModuleName
    }
    catch {
        Write-Warning $_
    }
    if ($AvailableModules) {
        $DoUpdateModule = $EnsureLatest
        if ((-not $DoUpdateModule) -and ($null -ne $MinimumVersion)) {
            if (-not ($AvailableModules | Where-Object { $_.Version -ge $MinimumVersion })) {
                $DoUpdateModule = $true
            }
        }
    }
    else {
        $DoInstallModule = $true
    }

    if ($DoUpdateModule) {
        Write-Host "Updating module '$ModuleName' ..."
        try {
            Write-Host "Ensuring latest version of module '$ModuleName'"
            $ResultObject = Register-PSRepositoryV3 -Uri $FeedUri
            $UpdateArgs = @{
                Name        = $ModuleName
                Scope       = $Scope
                Credential  = $Credentials
                Repository  = $ResultObject.FeedName
                ErrorAction = "Stop"
            }
            if ($MinimumVersion) {
                $UpdateArgs.Version += "[$($MinimumVersion), ]"
            }
            Update-PSResource @UpdateArgs
        }
        catch {
            Write-Host "Failed to update module '$ModuleName': $($_.Exception.Message)"
        }
        finally {
            if ($ResultObject.IsTemporary) {
                Write-Host "Removing temporary gallery '$($ResultObject.FeedName)'"
                Unregister-PSRepositoryV3 -Name $ResultObject.FeedName
            }
            $ResultObject = $null
        }
    }

    if ($DoInstallModule) {
        Write-Host "No versions found for module '$ModuleName', installing ..."
        Install-PsModule -ModuleName $ModuleName -Scope $Scope -FeedUri $FeedUri -Credentials $Credentials
    }

    Import-Module $ModuleName -DisableNameChecking -Global:$Global -MinimumVersion $MinimumVersion
}

Export-ModuleMember Import-PsModule