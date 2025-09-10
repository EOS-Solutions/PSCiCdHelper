function Get-NugetCredentials {
    <#
    .SYNOPSIS
    Extracts credentials from NuGet endpoint environment variables for a given feed URI.
    
    .DESCRIPTION
    This function searches for NuGet endpoint configurations stored in the VSS_NUGET_EXTERNAL_FEED_ENDPOINTS 
    environment variable that match the beginning of the provided feed URI and returns the associated 
    credentials if found.
    
    .PARAMETER FeedUri
    The full NuGet feed URI to search for matching endpoint configurations.
    
    .EXAMPLE
    Get-NugetCredentials -FeedUri "https://pkgs.dev.azure.com/myorg/myproject/_packaging/myfeed/nuget/v3/index.json"
    
    .EXAMPLE
    Get-NugetCredentials -FeedUri "https://nuget.example.com/v3/index.json"
    
    .OUTPUTS
    PSCredential object containing the username and password for the matching endpoint, or $null if no match found.
    #>
    
    param(
        [Parameter(Mandatory = $true)]
        [String] $FeedUri
    )
    
    Write-Verbose "Searching for credentials matching feed URI: $FeedUri"
    
    # Check for VSS_NUGET_EXTERNAL_FEED_ENDPOINTS environment variable
    $endpointsJson = $env:VSS_NUGET_EXTERNAL_FEED_ENDPOINTS
    
    if (-not $endpointsJson) {
        Write-Verbose "VSS_NUGET_EXTERNAL_FEED_ENDPOINTS environment variable not found"
        return $null
    }
    
    try {
        # Parse the JSON from the environment variable
        $endpoints = $endpointsJson | ConvertFrom-Json
        
        # Convert feed URI to lowercase for comparison
        $FeedUriLower = $FeedUri.ToLowerInvariant()
        
        # Find matching endpoint
        $matchingEndpoint = $null
        foreach ($endpoint in $endpoints.endpointCredentials) {
            $endpointUri = $endpoint.endpoint.ToLowerInvariant()
            
            # Check if the feed URI starts with the endpoint URI or vice versa
            if ($FeedUriLower.StartsWith($endpointUri) -or $endpointUri.StartsWith($FeedUriLower)) {
                $matchingEndpoint = $endpoint
                Write-Verbose "Found matching endpoint: $($endpoint.endpoint)"
                break
            }
        }
        
        if (-not $matchingEndpoint) {
            Write-Verbose "No matching endpoint found for URI: $FeedUri"
            return $null
        }
        
        # Extract username and password from the matching endpoint
        $username = $matchingEndpoint.username
        $password = $matchingEndpoint.password
        
        if (-not $username -or -not $password) {
            Write-Verbose "Incomplete credentials found for endpoint: $($matchingEndpoint.endpoint)"
            return $null
        }
        
        Write-Verbose "Successfully extracted credentials for endpoint: $($matchingEndpoint.endpoint)"
        
        # Create and return PSCredential object
        $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
        return New-Object System.Management.Automation.PSCredential($username, $securePassword)
        
    }
    catch {
        Write-Error "Error parsing VSS_NUGET_EXTERNAL_FEED_ENDPOINTS: $($_.Exception.Message)"
        return $null
    }
}

Export-ModuleMember Get-NugetCredentials
