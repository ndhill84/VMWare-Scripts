<#
.SYNOPSIS
  Pulls key VMKport information  

.DESCRIPTION
  Get VMKernel Port informaiton for all hosts connected to a virtual switch specified.

.PARAMETERS 
    -VirtualSwitch <VirtualSwitchBase[]>
    Specifies the virtual switches to which network adapters that you want to retrieve are connected. Can be local vSwitch or vDS.

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
    c:\>.\Get-VMKernelPortInfo.ps1 -VirtualSwtich vDS-16Switches -FileName Lab-VMKports.txt

.EXAMPLE
    c:\>.\Get-VMKernelPortInfo.ps1 -VirtualSwtich vSwitch0 -FileName Lab-VMKports.txt
#>

#Check for VMware PS Module
$loaded = get-module VMware.VimAutomation.Core
    if(!$loaded) { import-module VMware.VimAutomation.Core }

param (
[parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true, HelpMessage="Virtual Switch to pull VMKports from")]$VirtualSwtich,
[parameter(Mandatory=$false, HelpMessage="Output to File. Folder must exist.")][String]$FileName=""
	)

if($FileName -ne ""){
    Get-VMHostNetworkAdapter -VirtualSwitch $VirtualSwtich -VMKernel | Select-Object VMHost, PortGroupName, IP, MTU | Sort-Object VMHost,PortGroupName | Format-Table | Out-File $FileName
} else {
    Get-VMHostNetworkAdapter -VirtualSwitch $VirtualSwtich -VMKernel | Select-Object VMHost, PortGroupName, IP, MTU | Sort-Object VMHost,PortGroupName | Format-Table
}
