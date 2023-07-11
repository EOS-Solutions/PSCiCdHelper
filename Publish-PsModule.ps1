function Publish-PsModule {

    param(
        [Parameter(Mandatory = $false)] [String] $ModuleFolder,
        [Parameter(Mandatory = $true)] [String] $FeedUri,
        [Parameter(Mandatory = $false)] [pscredential] $Credentials,
        [Parameter(Mandatory = $false)] [String] $ApiKey
    )

    if (-not $ModuleFolder) {
        $ModuleFolder = $env:PIPELINE_WORKSPACE
        if (-not $ModuleFolder) {
            Write-Warning "No module folder specified and the variable 'PIPELINE_WORKSPACE' is not defined. Exiting ..."
            return
        }
    }

    $PsModules = Get-ChildItem $ModuleFolder -Filter *.psd1 -Recurse
    if (-not $PsModules) {
        Write-Host "No PS Modules found in '$ModuleFolder', exiting ..."
        return
    }

    try {
        Write-Host "Registering gallery for $FeedUri"
        $ResultObject = Register-PSRepositoryV3 -Uri $FeedUri
        Write-Host "Using gallery $($ResultObject.FeedName)"

        foreach ($PsModule in $PsModules) {
            $ModuleFilename = $PsModule.FullName
            $ModuleName = [IO.Path]::GetFileNameWithoutExtension($ModuleFilename)
            $ModuleFolder = [IO.Path]::GetDirectoryName($ModuleFilename)

            Write-Host "Publishing module '$ModuleFilename'"
            $TempModuleFolder = [IO.Path]::Combine([IO.Path]::GetTempPath(), [Guid]::NewGuid(), $ModuleName)
            try {
                [IO.Directory]::CreateDirectory($TempModuleFolder) | Out-Null
                Get-ChildItem $ModuleFolder | Copy-Item -Destination $TempModuleFolder -Recurse
                $ArgObject = @{
                    Path       = $TempModuleFolder
                    ApiKey     = $ApiKey
                    Repository = $ResultObject.FeedName
                }
                if ($Credentials) {
                    $ArgObject += @{ Credential = $Credentials }
                }
                Publish-PSResource @ArgObject
                Write-Host "The module '$ModuleName' from '$ModuleFolder' has been published."
            }
            finally {
                if ([IO.Directory]::Exists($TempModuleFolder)) {
                    [IO.Directory]::Delete($TempModuleFolder, $true)
                }
            }
        }

    }
    finally {
        if ($ResultObject.IsTemporary) {
            Write-Host "Removing temporary gallery '$($ResultObject.FeedName)'"
            Unregister-PSRepositoryV3 -Name $ResultObject.FeedName
        }
    }
}

Export-ModuleMember Publish-PsModule