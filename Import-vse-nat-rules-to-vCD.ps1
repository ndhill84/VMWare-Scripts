# Run from a PowerCLI shell that has been logged into the vCloud Director instance using “Connect-CIServer -server vpdc.phoenixnap.com” 
# and then run the script passing the following parameters:
#  -file or -f = The CSV file to import rules from
#  -edge or -e = The Edge Gateway Name to import rules into

# Example:
#   ./import-vse-nat-rules.ps1 -f cloudinf-nat-rules.csv -e “Testing-Edge”


param (
[parameter(Mandatory = $true, HelpMessage="Edge Gateway Name")][alias("-edge","e")][ValidateNotNullOrEmpty()][string[]]$egwname,
[parameter(Mandatory = $true, HelpMessage="CSV Path")][alias("-file","f")][ValidateNotNullOrEmpty()][string]$csvFile
)
   
#Search for vSE
try {
  $edgeView = Search-Cloud -QueryType EdgeGateway -Name $egwname -ErrorAction Stop | Get-CIView
} catch {
[System.Windows.Forms.MessageBox]::Show("Exception: " + $_.Exception.Message + " - Failed item:" + $_.Exception.ItemName ,"Error.",0,[System.Windows.Forms.MessageBoxIcon]::Exclamation)
  Exit
}
 
$URI = ($edgeview.Href + "/action/configureServices")
$wc = New-Object System.Net.WebClient
$wc.Headers.Add("x-vcloud-authorization", $Edgeview.Client.SessionKey)
$wc.Headers.Add("Content-Type", "application/vnd.vmware.admin.edgeGatewayServiceConfiguration+xml")
$wc.Headers.Add("Accept", "application/*+xml;version=5.1")
$webclient = New-Object system.net.webclient
$webclient.Headers.Add("x-vcloud-authorization",$Edgeview.Client.SessionKey)
$webclient.Headers.Add("accept",$EdgeView.Type + ";version=5.1")
 
$EGWConfXML = $webclient.DownloadString($EdgeView.href)
$OriginalXML = $EGWConfXML.EdgeGateway.Configuration.EdgegatewayServiceConfiguration.NatService.outerxml
 
$strXML = ""
 
Ipcsv -path $csvFile |
foreach-object `
{
    $ExternalNetwork = Get-ExternalNetwork $_.AppliedOn
     
    $strXML += '       <NatRule>
        <RuleType>' + $_.Type + '</RuleType>
        <IsEnabled>' + $_.Enabled.ToLower() + '</IsEnabled>
        <Id>' + $_.ID + '</Id>
        <GatewayNatRule>
            <Interface type="application/vnd.vmware.admin.network+xml" name="' + $ExternalNetwork.Name + '" href="' + $ExternalNetwork.Href + '"/>'
 
    if ($_.Type -eq "SNAT")
    {
        $strXML += '
            <OriginalIp>' + $_.OriginalIP + '</OriginalIp>
            <TranslatedIp>' + $_.TranslatedIP + '</TranslatedIp>'
    }
     
    if ($_.Type -eq "DNAT")
    {
        $strXML += '
            <OriginalIp>' + $_.OriginalIP + '</OriginalIp>
            <OriginalPort>' + $_.OriginalPort + '</OriginalPort>
            <TranslatedIp>' + $_.TranslatedIP + '</TranslatedIp>
            <TranslatedPort>' + $_.TranslatedPort + '</TranslatedPort>
            <Protocol>' + $_.Protocol + '</Protocol> '      
    }
     
    $strXML += '
        </GatewayNatRule>
       </NatRule>
'
     
}   
     
$GoXML = '<?xml version="1.0" encoding="UTF-8"?>
<EdgeGatewayServiceConfiguration xmlns="http://www.vmware.com/vcloud/v1.5" >
   <NatService>
       <IsEnabled>true</IsEnabled>
'
$GoXML += $StrXML
$GoXML += '</NatService>
</EdgeGatewayServiceConfiguration>'
 
[byte[]]$byteArray = [System.Text.Encoding]::ASCII.GetBytes($GoXML) 
$UploadData = $wc.Uploaddata($URI, "POST", $bytearray)  