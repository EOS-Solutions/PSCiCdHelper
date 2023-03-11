try {
    Import-Module PowerShellGet -MinimumVersion 3.0.0
}
catch {
    Install-Module PowerShellGet -MinimumVersion 3.0.0-beta19 -AllowPrerelease -Force
    Import-Module PowerShellGet -MinimumVersion 3.0.0
}

. "$PSScriptRoot\Initialize-NuGetFeed.ps1"
. "$PSScriptRoot\Register-PSRepositoryWithSource.ps1"
. "$PSScriptRoot\Unregister-PSRepositoryWithSource.ps1"
. "$PSScriptRoot\Publish-PsModule.ps1"
. "$PSScriptRoot\Install-PsModule.ps1"