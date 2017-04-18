<#
.SYNOPSIS
  Sets MTU of all VMKernel Ports on a Virtual Switch to 9000.  

.DESCRIPTION
  Sets MTU of all VMKernel Ports on a Virtual Switch to 9000.

.PARAMETERS 
    -VirtualSwitch <VirtualSwitchBase[]>
    Specifies the virtual switches that contains the VMKernel ports you want to set the MTU of. Can be local vSwitch or vDS.

    -FileName <String[]>
    Name of file to output the results to.
  
.OUTPUTS
    VMHost, PortGroupName, IP and MTU of each host connected to the specified virtual switch.

.NOTES
    Version:        1.0
    Author:         Nick Hill
    Creation Date:  02/12/2017
    Purpose/Change: Initial script development

.EXAMPLE
    c:\>.\Set-VMKernelMTU9000.ps1 -VirtualSwtich vDS-16Switches -FileName Lab-VMKports.txt

.EXAMPLE
    c:\>.\Set-VMKernelMTU9000.ps1 -VirtualSwtich vSwitch0 -FileName Lab-VMKports.txt
#>
param (
[parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true, HelpMessage="Virtual Switch to pull VMKports from")]$VirtualSwtich,
[parameter(Mandatory=$false, HelpMessage="Output to File. Folder must exist.")][String]$FileName=""
	)


$loaded = get-module VMware.VimAutomation.Core
    if(!$loaded) { import-module VMware.VimAutomation.Core }

$vmks = Get-VMHostNetworkAdapter -VirtualSwitch $VirtualSwtich -VMKernel

$vmks | foreach{ 
    $_ | Set-VMHostNetworkAdapter -Mtu 9000 -Confirm:$false
}
if($FileName -ne ""){
    Get-VMHostNetworkAdapter -VirtualSwitch $VirtualSwtich -VMKernel | Select-Object VMHost, PortGroupName, IP, MTU | Sort-Object VMHost,PortGroupName | Format-Table | Out-File $FileName

} else {
    Get-VMHostNetworkAdapter -VirtualSwitch $VirtualSwtich -VMKernel | Select-Object VMHost, PortGroupName, IP, MTU | Sort-Object VMHost,PortGroupName | Format-Table
}