function Unregister-PSRepositoryWithSource {

    param(
        # The name of the PS gallery to be registered. This is mandatory if you use 'NonTemporary'. Otherwise a random name will be generated.
        [Parameter(Mandatory = $true)] [string] $Name
    )

    PowerShellGet\Unregister-PSRepository -Name $Name
    PackageManagement\Unregister-PackageSource -Source "$($Name)_NuGet"

}

Export-ModuleMember Unregister-PSRepositoryWithSource