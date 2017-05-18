<#
.SYNOPSIS
  Export NAT Rules from vShield/NSX Edge Devices managed by vCloud Director
.OUTPUTS
    vShield Edge/NSX Edge NAT Rules, from vCloud Director, into a CSV File.
.NOTES
    Version:        1.3
    Author:         Nick Hill
    email:          ndhill@gmail.com
    website:        github.com/ndhill84/
    Creation Date:  11/16/2016
    Purpose/Change: Anonymize for Posting. 

    You can set the output to use unique filenames if you don't want the export to overwrite the old file each time.
    Set $var_Unique = $true
.EXAMPLE
    .\Export-Edge-NAT-Rules.ps1 -EdgeName "TestOrg_Edge"
#>
param (
    [parameter(Mandatory = $true, HelpMessage = "Edge Gateway Name")][alias("-edge", "e")][ValidateNotNullOrEmpty()][string[]]$EdgeName
)
#Set CSV filename
[string]$csvFile = $EdgeName + "NAT-Export.csv"  

$var_Edge = Search-Cloud -QueryType EdgeGateway -Name $EdgeName | Get-CIView
if (!$var_Edge) {
    Write-Host -ForegroundColor Red "Edge Gateway $EdgeName not found! Exiting..."
    Exit
}

$var_HTTP = New-Object System.Net.WebClient
$var_HTTP.Headers.Add("x-vcloud-authorization", $var_Edge.Client.SessionKey)
$var_HTTP.Headers.Add("accept", $var_Edge.Type + ";version=5.1")
[XML]$var_EdgeXML = $var_HTTP.DownloadString($var_Edge.Href)
if (!$var_EdgeXML) {
    Write-Host -ForegroundColor Red "Error Collecting XML Data for $EdgeName."
    Exit
}

$var_NatRules = $var_EdgeXML.EdgeGateway.Configuration.EdgegatewayServiceConfiguration.NatService.Natrule

$var_AllRules = @()
if ($var_NatRules) {

    $var_NatRules | ForEach-Object {

        $var_NewRuleExport = new-object PSObject           
        $var_NewRuleExport | Add-Member -Type NoteProperty -Name Description -Value $_.Description
        $var_NewRuleExport | Add-Member -Type NoteProperty -Name AppliedOn -Value $_.GatewayNatRule.Interface.Name
        $var_NewRuleExport | Add-Member -Type NoteProperty -Name Type -Value $_.RuleType.ToUpper()
        $var_NewRuleExport | Add-Member -Type NoteProperty -Name OriginalIP -Value $_.GatewayNatRule.OriginalIP
        $var_NewRuleExport | Add-Member -Type NoteProperty -Name OriginalPort -Value $_.GatewayNatRule.OriginalPort
        $var_NewRuleExport | Add-Member -Type NoteProperty -Name TranslatedIP -Value $_.GatewayNatRule.TranslatedIP
        $var_NewRuleExport | Add-Member -Type NoteProperty -Name TranslatedPort -Value $_.GatewayNatRule.TranslatedPort
        $var_NewRuleExport | Add-Member -Type NoteProperty -Name Protocol -Value $_.GatewayNatRule.Protocol
        $var_NewRuleExport | Add-Member -Type NoteProperty -Name Enabled -Value ([string]$_.IsEnabled.ToLower())
        $var_NewRuleExport | Add-Member -Type NoteProperty -Name ID -Value $_.ID

        $var_AllRules += $var_NewRuleExport
    }

}

else {
    Write-Host -ForegroundColor Red "No NAT Rules found for $EdgeName."
}
$var_AllRules | Export-CSV -Path $csvFile -NoType