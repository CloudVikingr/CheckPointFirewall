<#
    .SYNOPSIS
    

    .DESCRIPTION
    

    .PARAMETER ApiUrl


    .PARAMETER Query


    .PARAMETER 


    .EXAMPLE


    .NOTES
    Author: Jason Wallace
    Date: October 2024
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

                # Parse REST response and create array of DomainEntry objects
                $results = $response.objects | ForEach-Object {
					try {
                            # Instantiate a new DomainEntry object for each log entry
                            [DomainEntry]::new($_)
                        } catch {
                            Write-Error "Error creating DomainEntry object: $_"
                            $null  # Optionally, return $null or handle the error as needed
                        }
				}

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