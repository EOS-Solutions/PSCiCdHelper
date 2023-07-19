function Unregister-PSRepositoryV3 {

    param(
        # The name of the PS gallery to be registered. This is mandatory if you use 'NonTemporary'. Otherwise a random name will be generated.
        [Parameter(Mandatory = $true)] [string] $Name
    )

    Unregister-PSResourceRepository -Name $Name

}

Export-ModuleMember Unregister-PSRepositoryV3