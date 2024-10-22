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
    The timeframe for the logs, default is "last-hour".

    .EXAMPLE
    $logs = Get-CheckPointLogs -ApiUrl "https://api.checkpoint.com" -Query "severity:high" -SessionId $sid
    $logs = Get-CheckPointLogs -ApiUrl "https://api.checkpoint.com" -Query "src:192.168.1.1" -Time-frame last-hour -SessionId $sid
    .NOTES
    Author: Jason Wallace
    #>
    function Get-CheckPointLogs {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory = $true,
                       HelpMessage = "Enter the base URL of the CheckPoint REST API.")]
            [ValidateNotNullOrEmpty()]
            [string]$ApiUrl,

            [Parameter(Mandatory = $true,
                       HelpMessage = "Enter the query string to filter the logs.")]
            [ValidateNotNullOrEmpty()]
            [string]$Query,

            [Parameter(Mandatory = $false,
                       HelpMessage = "Enter the timeframe for the logs.")]
            [ValidateSet(
            "last-7-days",
            "last-hour",
            "today",
            "last-24-hours",
            "yesterday",
            "this-week",
            "this-month",
            "last-30-days",
            "all-time"
            )]
            [string]$TimeFrame = "last-hour",

            [Parameter(Mandatory = $true,
            HelpMessage = "Enter the PSCredential object for API authentication.")]
            [ValidateNotNullOrEmpty()]
            [System.Management.Automation.PSCredential]$Credential

        )

        begin {
            Write-Verbose "Preparing to retrieve logs from CheckPoint API at $ApiUrl."
            $token = Connect-CheckPointProvider -ApiUrl $ApiUrl -Credential $cred
        }

        process {
            try {
                $results = @()
                $headers = @{ "X-chkp-sid" = $token }

                $queryId = $null

                $body = @{
                    'new-query' = @{
                        'filter'     = $Query
                        'time-frame' = $TimeFrame
                    }
                }

                $Count = 0
                # Start the indeterminate progress indicator
                Write-Progress -Activity " Retrieving logs..." -Status "Initializing...0 records retrieved"

                do {

                    $response = Invoke-RestMethodIgnoreCertValidation -Method Post -Uri "$ApiUrl/show-logs" -Body $body -Headers $headers
                    Write-Verbose "Logs retrieved successfully."

                    $results += $response.logs | ForEach-Object {
                        try {
                            # Instantiate a new LogEntry object for each log entry
                            [LogEntry]::new($_)
                        } catch {
                            Write-Error "Error creating LogEntry object: $_"
                            $null  # Optionally, return $null or handle the error as needed
                        }
                    }

                    $body = @{ 'query-id' = $response.'query-id' }
                    $count += $response.'logs-count'
                    Write-Progress -Activity "Downloading logs..." -Status "$count downloaded"
                } while ($response.'logs-count' -eq 100)

                Write-Progress -Activity "Downloading logs complete" -Status "$count downloaded"

                return $results
            }
            catch {
                Write-Error "An error occurred while retrieving logs: $_"
            }
            finally {
                Write-Progress -Activity "Downloading files..." -Completed
            }
        }

        end {
            Disconnect-CheckPointProvider -ApiUrl $ApiUrl -Token $token
            Write-Verbose "Log retrieval process completed."
        }
    } # Get-CheckPointLogs