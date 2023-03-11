$Uri = "https://github.com/hemisphera/PsCiCdHelper/archive/refs/heads/main.zip"
$ErrorActionPreference = "Stop"
$Filename = "$([IO.Path]::GetTempFileName()).zip"
$TempFolder = [IO.Path]::Combine([IO.Path]::GetTempPath(), "PsCiCdHelper")
Write-Host "Using temporary folder '$TempFolder'"
if ([IO.Directory]::Exists($TempFolder)) { [IO.Directory]::Delete($TempFolder, $true) }
try {
    Write-Host "Downloading from '$Uri'"
    Invoke-WebRequest -Uri $Uri -OutFile $Filename -Headers @{"Cache-Control" = "no-cache" }
    Expand-Archive $Filename -DestinationPath $TempFolder
    Rename-Item "$TempFolder\PsCiCdHelper-main" "$TempFolder\PsCiCdHelper"
}
finally {
    if ([IO.File]::Exists($Filename)) { [IO.File]::Delete($Filename) }
}
$ModulePath = "$TempFolder\PsCiCdHelper\PsCiCdHelper.psm1"

Write-Host "Importing module from '$ModulePath'"
$DebugPreference = 'Continue'

Import-Module "$ModulePath"
Get-Module