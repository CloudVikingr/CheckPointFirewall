function Invoke-RestMethodIgnoreCertValidation {
	[CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Uri,

        [Parameter(Mandatory = $false)]
        [object]$Headers = @{},

        [Parameter(Mandatory = $false)]
        [object]$Body = @{},

        [Parameter(Mandatory = $false)]
        [string]$Method = "GET"
    )

    # Save the current SSL certificate validation callback
    $originalCallback = [System.Net.ServicePointManager]::ServerCertificateValidationCallback

    try {
        # Set SSL certificate validation callback to always return true
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { return $true }

        # Convert Body to JSON 
        $Body = $Body | ConvertTo-Json
        
        # Prepare parameters for Invoke-WebRequest
        $parameters = @{
            "Uri"         = $Uri
            "Method"      = $Method
            "Headers"     = $Headers
            "ContentType" = "application/json"
            "Body"        = $Body
        }


        # Invoke the web request
        #$response = Invoke-RestMethod -Uri $uri -Method $Method -Headers $Headers -Body $Body 
        #$response = Invoke-RestMeth
        #$response = Invoke-RestMethod -Method Post -Uri "$Uri" -Body $Body -Headers $Headers
        $response = Invoke-RestMethod @parameters

        # Return the response
        return $response
    } catch {
        throw $_
    } finally {
        # Restore the original SSL certificate validation callback
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = $originalCallback
    }
}
