<#
.SYNOPSIS
Connects to the CheckPoint REST API and retrieves an authentication token.

.DESCRIPTION
This function establishes a connection to the CheckPoint REST API by sending authentication credentials and retrieving a token for further API calls. It also allows for ignoring SSL errors, which is enabled by default.

.PARAMETER ApiUrl
The base URL of the CheckPoint REST API.

.PARAMETER Credential
The PSCredential object for API authentication. Required if Token is not provided.

.PARAMETER Token
An existing authentication token if available.

.PARAMETER IgnoreSslErrors
Switch to ignore SSL certificate errors. Enabled by default.

.NOTES
Author: Jason Wallace
Date: August 2024
Version: 1.1
#>
function Connect-CheckPointProvider {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            HelpMessage = "Enter the base URL of the CheckPoint REST API.")]
        [ValidateNotNullOrEmpty()]
        [string]$ApiUrl,

        [Parameter(
            Mandatory = $false,
            HelpMessage = "Enter the PSCredential object for API authentication.")]
        [System.Management.Automation.PSCredential]$Credential,

        [Parameter(
            Mandatory = $false,
            HelpMessage = "Credentials won't be cached")]
        [switch] $NoCacheCredential
    )

    begin {
        Write-Verbose "Initializing connection to CheckPoint API at $ApiUrl."
    }

    process {
        try {
            # Determine which credential to use
            if ($Credential) {
                $CurrentCredential = $Credential
                if (-not $NoCacheCredential) {
                    $Global:CachedCheckpointCredential = $Credential
                    Write-Verbose "Credential provided. Updating cached credential."
                } else {
                    Write-Verbose "Credential provided but not caching due to -NoCacheCredential switch."
                }
            } elseif ($Global:CachedCheckpointCredential) {
                $CurrentCredential = $Global:CachedCheckpointCredential
                Write-Verbose "Using cached credential."
            } else {
                Write-Verbose "No credential provided and no cached credential found. Prompting for credentials."
                $CurrentCredential = Get-Credential -Message "Enter your Check Point firewall credentials"
                Write-Verbose "Credentials Entered."
                if (-not $NoCacheCredential) {
                    $Global:CachedCheckpointCredential = $CurrentCredential
                    Write-Verbose "Caching Credentials."
                }
            }

            # Extract username and password from the CurrentCredential object
            $Username = $CurrentCredential.GetNetworkCredential().UserName
            $Password = $CurrentCredential.GetNetworkCredential().Password

            # Construct the authentication body
            $body = @{
                user     = $Username
                password = $Password
            }

            # Make the REST API call to authenticate
            $response = Invoke-RestMethodIgnoreCertValidation -Uri "$ApiUrl/login" -Method Post -Body $body

            if ($response -and $response.sid) {
                Write-Verbose "Authentication successful. Token received."
                $Token = $response.sid
            } else {
                throw "Failed to authenticate. No token received."
            }
            # Return the token for further API calls
            return $Token
        } catch {
            Write-Error "An error occurred during connection: $_"
        }
    }
    end {

        Write-Verbose "Connection attempt completed."
    }
} # Connect-CheckPointProvider