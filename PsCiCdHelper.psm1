try {
    Import-Module Microsoft.PowerShell.PSResourceGet -Global
}
catch {
    Install-Module Microsoft.PowerShell.PSResourceGet -AllowPrerelease -Force
    Import-Module Microsoft.PowerShell.PSResourceGet -Global
}

. "$PSScriptRoot\Initialize-NuGetFeed.ps1"
. "$PSScriptRoot\Register-PSRepositoryV3.ps1"
. "$PSScriptRoot\Unregister-PSRepositoryV3.ps1"
. "$PSScriptRoot\Publish-PsModule.ps1"
. "$PSScriptRoot\Install-PsModule.ps1"
. "$PSScriptRoot\Import-PsModule.ps1"