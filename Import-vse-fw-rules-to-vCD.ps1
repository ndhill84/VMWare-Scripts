# Run from a PowerCLI shell that has been logged into the vCloud Director instance using “Connect-CIServer -server vpdc.phoenixnap.com” 
# and then run the script passing the following parameters:
#   -file or -f = The CSV file containing the rules to import
#   -edge or -e = The Edge Gateway Name
#
# Example:
#   ./import-vse-fw-rules.ps1 -f Testing-FW-Rules.csv -e “Testing-Edge”
 
param (
[parameter(Mandatory = $true, HelpMessage="Edge Gateway Name")][alias("-edge","e")][ValidateNotNullOrEmpty()][string[]]$egwname,
[parameter(Mandatory = $true, HelpMessage="CSV Path")][alias("-file","f")][ValidateNotNullOrEmpty()][string[]]$csvFile
)
 
#Search EdgeGW
try {
$edgeView = Search-Cloud -QueryType EdgeGateway -Name $egwname -ErrorAction Stop | Get-CIView
} catch {
[System.Windows.Forms.MessageBox]::Show("Exception: " + $_.Exception.Message + " - Failed item:" + $_.Exception.ItemName ,"Error.",0,[System.Windows.Forms.MessageBoxIcon]::Exclamation)
Exit
}
 

$fwService = New-Object vmware.vimautomation.cloud.views.firewallservice
$fwService.DefaultAction = "drop"
$fwService.LogDefaultAction = $false
$fwService.IsEnabled = $true
$fwService.FirewallRule = @()
$rowNum = 0
 
Ipcsv -path $csvFile |
foreach-object `
{
$fwService.FirewallRule += New-Object vmware.vimautomation.cloud.views.firewallrule
 
$fwService.FirewallRule[$rowNum].description = $_.Descr
$fwService.FirewallRule[$rowNum].protocols = New-Object vmware.vimautomation.cloud.views.firewallRuleTypeProtocols
switch ($_.Proto)
{
"tcpudp" { $fwService.FirewallRule[$rowNum].protocols.tcp = $true
$fwService.FirewallRule[$rowNum].protocols.udp = $true }
"tcp" { $fwService.FirewallRule[$rowNum].protocols.tcp = $true }
"udp" { $fwService.FirewallRule[$rowNum].protocols.udp = $true }
"any" { $fwService.FirewallRule[$rowNum].protocols.any = $true }
default { $fwService.FirewallRule[$rowNum].protocols.any = $true }
}
$fwService.FirewallRule[$rowNum].sourceip = $_.SrcIP
 
if ($_.SrcPort -eq "any" ) { $srcPort = "-1" } else { $srcPort = $_.SrcPort }
$fwService.FirewallRule[$rowNum].sourceport = $srcPort
$fwService.FirewallRule[$rowNum].destinationip = $_.DstIP
$fwService.FirewallRule[$rowNum].destinationportrange = $_.DstPortRange
$fwService.FirewallRule[$rowNum].policy = $_.Policy
$fwService.FirewallRule[$rowNum].isenabled = [System.Convert]::ToBoolean($_.isEnabled)
$fwService.FirewallRule[$rowNum].enablelogging = [System.Convert]::ToBoolean($_.EnableLogging)
 
$rowNum++
 
}
 
#configure Edge
$edgeView.ConfigureServices($fwService)