#Pull NAT Rules for a specific Edge from NSX manager and export them to XML file.

# Example Edge Names: 
# "vse-Customer-Edge (6f67eae0-112a-4a9f-b01d-cc1c86304eee)"
# "vse-Testing_Edge (1f9a40e2-65432-429d-a7cb-63db54c34a15)"

#Full name of the Edge
$NATRules = Get-NsxEdge -Name "NSX-EDGE (GUID)" | Get-NsxEdgeNat | Get-NsxEdgeNatRule


[int]$RID = 65537

$Rules = @()
if ($NATRules){
  $NATRules | ForEach-Object {
		if ($_.ruleTag -eq 196785){
			$_.ruleTag = "131070"
		}
		if ($_.ruleTag -eq 196785){
			$_.ruleTag = "131071"
		}
		if ($_.vnic -eq 0){
			$_.vnic = "EXTERNAM-NETWORK-NAME"
		}
		if ($_.vnic -eq 2){
			$_.vnic = "INTERNAL NETWORK NAME"
		}
       $NewRule = new-object PSObject -Property @{
	   Description = $_.Description;
	   AppliedOn = $_.vnic;
       Type = [string]$_.action.ToUpper();
       OriginalIP = $_.originalAddress;
       OriginalPort = $_.originalPort;
       TranslatedIP = $_.translatedAddress;
       TranslatedPort = $_.translatedPort;
       Protocol = $_.protocol;
       Enabled = [string]$_.enabled.ToLower();
       ID = $_.ruleTag;
   }
       $Rules += $NewRule
	   $RID++
   }
}
$Rules | Export-CSV -Path Celenia-Complete.csv -NoType