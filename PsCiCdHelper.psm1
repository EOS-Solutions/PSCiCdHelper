try {
    Import-Module PowerShellGet -MinimumVersion 3.0.19 -Global
}
catch {
    Install-Module PowerShellGet -MinimumVersion 3.0.19-beta19 -AllowPrerelease -Force
    Import-Module PowerShellGet -MinimumVersion 3.0.19 -Force -Global
}

. "$PSScriptRoot\Initialize-NuGetFeed.ps1"
. "$PSScriptRoot\Register-PSRepositoryWithSource.ps1"
. "$PSScriptRoot\Unregister-PSRepositoryWithSource.ps1"
. "$PSScriptRoot\Publish-PsModule.ps1"
. "$PSScriptRoot\Install-PsModule.ps1"
. "$PSScriptRoot\Import-PsModule.ps1"