Import-Module PackageManagement -MinimumVersion 1.4.8.1
Import-Module PowerShellGet -MinimumVersion 2.2.5

. "$PSScriptRoot\Register-PSRepositoryWithSource.ps1"
. "$PSScriptRoot\Unregister-PSRepositoryWithSource.ps1"
. "$PSScriptRoot\Publish-PsModule.ps1"
. "$PSScriptRoot\Install-PsModule.ps1"