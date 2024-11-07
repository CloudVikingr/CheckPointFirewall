<#
.SYNOPSIS
Disconnects from the CheckPoint REST API by terminating the session.

.DESCRIPTION
This function logs out from the CheckPoint REST API by invalidating the session token.

.PARAMETER ApiUrl
The base URL of the CheckPoint REST API.

.PARAMETER Token
The session token that needs to be invalidated.

.EXAMPLE
Disconnect-CheckPointProvider -ApiUrl "https://api.checkpoint.com" -Token $token

.NOTES
Author: Jason Wallace
Date: August 2024
Version: 1.0
#>
function Disconnect-CheckPointProvider {
    

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, 
                   HelpMessage = "Enter the base URL of the CheckPoint REST API.")]
        [ValidateNotNullOrEmpty()]
        [string]$ApiUrl,

        [Parameter(Mandatory = $true, 
                   HelpMessage = "Enter the session token to invalidate.")]
        [ValidateNotNullOrEmpty()]
        [string]$Token
    )

    begin {
        Write-Verbose "Initializing disconnection from CheckPoint API at $ApiUrl."
    }

    process {
        try {
            # Define the session ID token in the header
            $headers = @{
                "X-chkp-sid"  = $Token
            }

            # Make the REST API call to log out
            $response = Invoke-RestMethodIgnoreCertValidation -Uri "$ApiUrl/logout" -Method Post -Headers $headers

            if ($response) {
                Write-Verbose "Successfully disconnected from the CheckPoint API."
            } else {
                throw "Failed to disconnect. No response received."
            }
        }
        catch {
            Write-Error "An error occurred during disconnection: $_"
        }
    }

    end {
        Remove-Variable -Name 'CachedCheckpointCredential' -Scope Global -ErrorAction SilentlyContinue
        Write-Verbose "Cached Credential cleared."
        Write-Verbose "Disconnection attempt completed."
    }
} # Disconnect-CheckPointProvider