$Uri = "https://github.com/EOS-Solutions/PSCiCdHelper/archive/refs/heads/main.zip"
$ErrorActionPreference = "Stop"

$PsCiCdHelperIndexPath = "$env:LOCALAPPDATA\.eos-pscicdhelper"
$RequiresDownload = (-not [IO.File]::Exists($PsCiCdHelperIndexPath))
if (-not $RequiresDownload) {
    $RequiresDownload = [IO.File]::GetLastWriteTime($PsCiCdHelperIndexPath) -lt (Get-Date).AddDays(-1)
}
if (-not $RequiresDownload) {
    $ModulePath = Get-Content $PsCiCdHelperIndexPath -Raw
}
else {
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
    Set-Content -Path $PsCiCdHelperIndexPath -Value $ModulePath
}

if ($env:System_Debug) { $DebugPreference = 'Continue' }
Write-Host "Importing module from '$ModulePath'"
Import-Module "$ModulePath"
Write-Output $ModulePath