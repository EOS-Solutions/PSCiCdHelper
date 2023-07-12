## What's this?

A tiny module that helps installing and deploying powershell modules in CI/CD scenarios. It is based on the new `Microsoft.PowerShell.PSResourceGet` (formerly known as `PowerShellGet v3`) and is therefore more awesome.

## Why?

1) It provides `Register-` and `Unregister-PSRepositoryV3` which allows to register a powershell gallery on-the-fly for deployment or installation.
2) It provides the compact `Publish-PSModule` as a one-liner to publish a package, registering & unregistering the feed automatically as required.
3) It provides `Import-PsModule` which allows to specify a feed when importing a module, from which the module is installed, if it isn't already.

## Installation

This is meant for CI/CD scenarios. The following will download the package and import it as a module. Drop this line into your pipeline scripts and you have the cmdlets readily available.

````
iex ". { $(irm https://raw.githubusercontent.com/EOS-Solutions/PSCiCdHelper/main/install.ps1 -Headers @{"Cache-Control" = "no-cache"}) }"
````