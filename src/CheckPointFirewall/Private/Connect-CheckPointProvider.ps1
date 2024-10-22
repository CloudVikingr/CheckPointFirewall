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
        [Parameter(Mandatory = $true,
                   HelpMessage = "Enter the base URL of the CheckPoint REST API.")]
        [ValidateNotNullOrEmpty()]
        [string]$ApiUrl,

        [Parameter(Mandatory = $false,
                   HelpMessage = "Enter the PSCredential object for API authentication.")]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]$Credential,

        [Parameter(Mandatory = $false,
                   HelpMessage = "Enter an existing token if available.")]
        [string]$Token,

        [Parameter(Mandatory = $false,
                   HelpMessage = "Fail on SSL certificate errors.")]
        [switch]$StrictSslErrors
    )

    begin {
        Write-Verbose "Initializing connection to CheckPoint API at $ApiUrl."
    }

    process {
        try {
            if (-not $Token) {
                if (-not $Credential) {
                    throw "Credential is required for authentication if Token is not provided."
                }

                # Extract username and password from the credential object
                $Username = $Credential.GetNetworkCredential().UserName
                $Password = $Credential.GetNetworkCredential().Password

                # Construct the authentication body
                $body = @{
                    user = $Username
                    password = $Password
                }

                # Make the REST API call to authenticate
                $response = Invoke-RestMethodIgnoreCertValidation -Uri "$ApiUrl/login" -Method Post -Body $body

                if ($response -and $response.sid) {
                    Write-Verbose "Authentication successful. Token received."
                    $Token = $response.sid
                }
                else {
                    throw "Failed to authenticate. No token received."
                }
            }
            else {
                Write-Verbose "Using provided token."
            }

            # Return the token for further API calls
            return $Token
        }
        catch {
            Write-Error "An error occurred during connection: $_"
        }
    }
    end {

        Write-Verbose "Connection attempt completed."
    }
} # Connect-CheckPointProvider