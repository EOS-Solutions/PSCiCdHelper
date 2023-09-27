function Import-PsModule {

    param(
        [Parameter(Mandatory = $true)] [String] $ModuleName,
        [Parameter(Mandatory = $true)] [String] $FeedUri,
        [Parameter(Mandatory = $false)] [pscredential] $Credentials,
        [Parameter(Mandatory = $false)] [switch] $EnsureLatest,
        [Parameter(Mandatory = $false)] [Version] $MinimumVersion = $null,
        [Parameter(Mandatory = $false)] [switch] $Global
    )

    $AvailableModules = Get-Module $ModuleName -ListAvailable
    if ($AvailableModules) {
        $DoUpdateModule = $EnsureLatest
        if ((-not $DoUpdateModule) -and ($null -ne $MinimumVersion)) {
            if ($AvailableModules | Where-Object { $_.Version -ge $MinimumVersion }) {
                $DoUpdateModule = $true
            }
        }
    }
    if ($DoUpdateModule) {
        try {
            Write-Host "Ensuring latest version of module '$ModuleName'"
            $ResultObject = Register-PSRepositoryV3 -Uri $FeedUri
            Update-PSResource -Name $ModuleName -Credential $Credentials -Repository $ResultObject.FeedName -ErrorAction Stop
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

    $Attempt = 0;
    $MaxAttempts = 3;
    while ($Attempt -lt $MaxAttempts) {
        $Attempt++
        if ($Attempt -gt $MaxAttempts) {
            throw "All attempts to import module '$ModuleName' failed"
        }
        try {
            if ($Attempt -gt 1) { Write-Host "Attempt $Attempt" }
            Import-Module $ModuleName -DisableNameChecking -Global:$Global -MinimumVersion $MinimumVersion
            break;
        }
        catch {
            Write-Host "Failed to import module '$ModuleName': $($_.Exception.Message)"
        }
        Write-Host "Installing module '$ModuleName' from '$FeedUri'"
        Install-PsModule -ModuleName $ModuleName -FeedUri $FeedUri -Credentials $Credentials
    }
}

Export-ModuleMember Import-PsModule