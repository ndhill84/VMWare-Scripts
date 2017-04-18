# Run from a PowerCLI shell that has been logged into the vCloud Director instance using “Connect-CIServer -server url” 
# and then run the script passing the following parameters:
#  -file or -f = The CSV file to export rules to
#  -edge or -e = The Edge Gateway Name
#
# Example:
#   ./export-vse-fw-rules.ps1 -f myfwrules.csv -e “My vShield Edge”
#

param (
[parameter(Mandatory = $true, HelpMessage="Edge Gateway Name")][alias("-edge","e")][ValidateNotNullOrEmpty()][string[]]$egwname,
[parameter(Mandatory = $true, HelpMessage="CSV Path")][alias("-file","f")][ValidateNotNullOrEmpty()][string]$csvFile
)
 
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
$webclient.Headers.Add("accept",$EdgeView.Type + ";version=5.5")
[XML]$EGWConfXML = $webclient.DownloadString($EdgeView.href)
$FWRules = $EGWConfXML.EdgeGateway.Configuration.EdgegatewayServiceConfiguration.FirewallService.FirewallRule
$Rules = @()
if ($FWRules){
$FWRules | ForEach-Object {
 
If ($_.Protocols.udp -And $_.Protocols.tcp) {$protocol = "tcpudp" }
elseif ($_.Protocols.udp) {$protocol = "udp"}
elseif ($_.Protocols.tcp) {$protocol = "tcp"}
elseif ($_.Protocols.any) {$protocol = "any"}
else{ $Protocol = "any"}
 
$NewRule = new-object PSObject -Property @{
Num = $_.ID;
Descr = $_.Description;
Proto = $Protocol;
SrcIP = $_.SourceIP;
SrcPort = $_.SourcePort;
DstIP = $_.DestinationIP;
DstPortRange = $_.DestinationPortRange;
Policy = $_.Policy;
Direction = "";
isEnabled = $_.IsEnabled;
EnableLogging = $_.EnableLogging;
MatchOnTranslate = $_.MatchOnTranslate;
 
}
$Rules += $NewRule
}
}
 
$Rules | Export-CSV -Path $csvFile -NoType