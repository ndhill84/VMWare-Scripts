# Run from a PowerCLI shell that has been logged into the vCloud Director instance using “Connect-CIServer -server url” 
# and then run the script passing the following parameters:
#  -edge or -e = The Edge Gateway Name

# Example:
#   ./export-vse-nat-rules.ps1 -e “My vShield Edge”

param (
[parameter(Mandatory = $true, HelpMessage="Edge Gateway Name")][alias("-edge","e")][ValidateNotNullOrEmpty()][string[]]$egwname
)
#Set CSV filename
[string]$csvFile = $egwname + "vCD-backup.csv"  

#Search EdgeGW
try {
  $edgeView = Search-Cloud -QueryType EdgeGateway -Name $egwname -ErrorAction Stop | Get-CIView
} catch {
[System.Windows.Forms.MessageBox]::Show("Exception: " + $_.Exception.Message + " - Failed item:" + $_.Exception.ItemName ,"Error.",0,[System.Windows.Forms.MessageBoxIcon]::Exclamation)
      Write-Warning "Edge Gateway with name $Edgeview not found"
      Exit
}
 
 
$webclient = New-Object system.net.webclient
$webclient.Headers.Add("x-vcloud-authorization",$Edgeview.Client.SessionKey)
$webclient.Headers.Add("accept",$EdgeView.Type + ";version=5.1")
[XML]$EGWConfXML = $webclient.DownloadString($EdgeView.href)

$NATRules = $EGWConfXML.EdgeGateway.Configuration.EdgegatewayServiceConfiguration.NatService.Natrule
$Rules = @()
if ($NATRules){
  $NATRules | ForEach-Object {
       $NewRule = new-object PSObject -Property @{
	   Description = $_.Description;
       AppliedOn = $_.GatewayNatRule.Interface.Name;
       Type = $_.RuleType.ToUpper();
       OriginalIP = $_.GatewayNatRule.OriginalIP;
       OriginalPort = $_.GatewayNatRule.OriginalPort;
       TranslatedIP = $_.GatewayNatRule.TranslatedIP;
       TranslatedPort = $_.GatewayNatRule.TranslatedPort;
       Protocol = $_.GatewayNatRule.Protocol;
       Enabled = [string]$_.IsEnabled.ToLower();
       ID = $_.ID;
   }
       $Rules += $NewRule
   }
}
$Rules | Export-CSV -Path $csvFile -NoType