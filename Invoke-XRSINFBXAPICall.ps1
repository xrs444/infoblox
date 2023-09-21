function Invoke-XRSINFBXAPICall {

  <#
    .SYNOPSIS
    Sends a Infoblox API request using the supplied parameters
  
    .DESCRIPTION
    Builds a REST API request from the given data and submits it to the specifed URI, and returns the response.
  
    .PARAMETER RequestUri
    Specifies the full URI for the request, including the https://
  
    .PARAMETER Payload
    Specifies the body of the request. If not specified the function defaults to empty JSON "{}".
  
    .PARAMETER $Method
    Specifies the REST API Call method, GET/PUT/POST/SET/DELETE
  
    .PARAMETER $DoNotConvert
    If this is set to true, the output is in the raw JSON, rather than a nice object you can select items from.
  
    .PARAMETER $Credential
    PS Credential object for authentication to the API
  
    .INPUTS
    There are no pipeline inputs currently configured.
  
    .OUTPUTS
    Returns the response from the server converted from JSON (Or not, if DoNotConvert is set to true)
  
    .EXAMPLE
    Invoke-XRSInfobloxAPICall -RequestURI "https://<GRIDURL>/wapi/v2.11.2/grid/b25lLmNsdXN0ZXIkMA:Infoblox?_function=restartservices" -Method GET -Credential $Credentials
  
  #>
  # Need Powershell 7+ for creds handling
  #Requires -Version 7.0
  
    param (
      [Parameter (Mandatory = $true,HelpMessage="Full request URI including port")] [String]$RequestUri,
      [Parameter (Mandatory = $false,HelpMessage="Body of the request")] [string]$Payload = "{}",
      [Parameter (Mandatory = $true,HelpMessage="REST call Method GET/PUT/ETC")] [String]$Method,
      [Parameter (Mandatory = $false,HelpMessage="Do not convert the native JSON output")] [bool]$DoNotConvert = $false,
      [Parameter (Mandatory = $false,HelpMessage="Convert the Payload to JSON if you don't want to")] [bool]$ConvertPayloadToJson = $false,
      [Parameter (Mandatory = $true,HelpMessage="Credentials as PSCredential object")]
      [ValidateNotNull()]
      [System.Management.Automation.PSCredential]
      [System.Management.Automation.Credential()]
      $Credential = [System.Management.Automation.PSCredential]::empty
    )
  
  # setup the request headers
  $Headers = @{
    'Accept' = 'application/json'
    'Content-Type' = 'application/json'
  }
  
  # If JSON conversion specified, then do it!
  
  if ($ConvertPayloadToJson -eq $true){
  
    $payload = ConvertTo-Json -InputObject $Payload -depth 20
  
  }
  
  # Submit the request
    $APIArgs = @{
  
      Uri = $RequestUri
      Headers = $Headers
      Method = $Method
      Body = $Payload
      TimeoutSec = '10'
      UseBasicParsing = $true
      DisableKeepAlive = $true
      Authentication = "Basic"
      Credential = $Credential
  
    }
  
    try{
  
    $Response = Invoke-WebRequest @APIArgs
    }
  
    Catch {
  
    $Response = $error
  
    Return $Response
  
  
    }
  
  If ($DoNotConvert -eq "True"){
  
    Return $Response
  
  }
  
  else{
  
    $Response = ConvertFrom-Json -InputObject $Response
    Return $response
  
  }
  
  }