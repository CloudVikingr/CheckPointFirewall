<#
    .SYNOPSIS
    Retrieves logs from the CheckPoint API based on the provided query.

    .DESCRIPTION
    This function constructs a request to the CheckPoint API to retrieve logs, using the specified query and session ID.

    .PARAMETER ApiUrl
    The base URL of the CheckPoint REST API.

    .PARAMETER Query
    The query string to filter the logs.

    .PARAMETER SessionId
    The session ID obtained during authentication.

    .PARAMETER TimeFrame
    The timeframe for the logs, default is "last-24-hours".

    .EXAMPLE
    $logs = Get-CheckPointDomains -ApiUrl "https://api.checkpoint.com" -Query "severity:high" -SessionId $sid

    .NOTES
    Author: Jason Wallace
    Date: August 2024
    Version: 1.0
    #>
    function Get-CheckPointDomains {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory = $true,
                       HelpMessage = "Enter the base URL of the CheckPoint REST API.")]
            [ValidateNotNullOrEmpty()]
            [string]$ApiUrl,

            [Parameter(Mandatory = $true,
            HelpMessage = "Enter the PSCredential object for API authentication.")]
            [ValidateNotNullOrEmpty()]
            [System.Management.Automation.PSCredential]$Credential

        )

        begin {
            Write-Verbose "Preparing to retrieve Domains from CheckPoint API at $ApiUrl."
            $token = Connect-CheckPointProvider -ApiUrl $ApiUrl -Credential $cred
        }

        process {
            try {
                # Construct the request body
                $body = @{
                    "details-level" = "Full"
                }

                # Define the headers including the session ID
                $headers = @{
                    "X-chkp-sid"  = $token
                }

                # Make the REST API call to retrieve logs
                $response = Invoke-RestMethodIgnoreCertValidation -Method Post -Uri "$ApiUrl/show-domains" -Body $body -Headers $headers

                Write-Verbose "Domains retrieved successfully."

                # Parse REST response and create array of LogEntry objects
                $results = $response.objects

                return $results
            }
            catch {
                Write-Error "An error occurred while retrieving Domains: $_"
            }
        }

        end {
            Disconnect-CheckPointProvider -ApiUrl $ApiUrl -Token $token
            Write-Verbose "Domain retrieval process completed."
        }
    } # Get-CheckPointDomainscd