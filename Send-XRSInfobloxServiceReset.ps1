
#### BETA SCRIPT FOR TESTING! NOT FINISHED PRODUCTION PRODUCT! ###

<#
    .SYNOPSIS
    Triggers a restart of all services requiring restart on the Infoblox platform.

    .DESCRIPTION
    This is used as a scheduled task to restart the Infoblox services that require it on a regular schedule

  #>

# Functions:

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
Function Alert {

# Insert your alerting code here. Perhaps an email or a API call to create a ticket in a queue.

  }


# Restart Service Config:

$Date = Get-Date -format "yyyyMMdd"
$Logfile = "C:\scripts\infoblox\logs\$($Date)-InfobloxServiceRestartLog.txt"
$Username = "<InfobloxAPIAcct>"
$Password = "<PASSWORD GOES HERE>"
$Password = ConvertTo-SecureString -String $Password -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ($Username, $Password)

$APICallArgs = @{

RequestUri = "https://<GridURL>/wapi/v2.11.2/grid/b25lLmNsdXN0ZXIkMA:Infoblox?_function=restartservices"
payload = @"
{"member_order" :"SEQUENTIALLY",
"sequential_delay": 60,
"service_option": "ALL"}
"@
Method = "POST"
Credential = $Credential

}

# Make the call

$Datestamp = get-date -format "yyyy-MM-dd HH:mm"

$Response = Invoke-XRSINFBXAPICall @APICallArgs

If ($response.GetType().Name -eq "PSCustomObject") {

  $LogEntry = $Datestamp + " - Restarts requested. No errors reported from API call"
  $LogEntry | Out-File -FilePath $Logfile -Append

}
Else{

  $LogEntry = $Datestamp + " - " + $Response.Exception.Message

  $LogEntry | Out-File -FilePath $Logfile -Append

  $Alert = @{
# Splatted alert params go here

  }

  Alert @AlertArgs

  $Error.Clear()

}



