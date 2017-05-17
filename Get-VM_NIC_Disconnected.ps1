<#
.SYNOPSIS
  Pulls all Network Adapters not Connected or set to Connect on Power-On
.OUTPUTS
    VM, AdapterName, AdapterType, MAC, NetworkName of NICs not set to Connect on Power-On. Option to export results to txt file with or w/o unique filenames.
.NOTES
    Version:        1.0
    Author:         Nick Hill
    email:          ndhill@gmail.com
    website:        github.com/ndhill84
    Creation Date:  05/16/2017
    Purpose/Change: Updated old script to get all disconnected NICs as well as not connected @ powerOn.

    You can set the output to use unique filenames if you don't want the export to overwrite the old file each time.
    Set $var_Unique = $true
.EXAMPLE
    c:\>.\Get-VM_nic_Disconnected.ps1
#>

#Use Uniquie Output FileName
$var_Unique = $false

#Output log info
[string]$var_local = Get-Location
[string]$var_date = Get-Date -Format "MMddyy.HHmmss"
if($var_Unique){
    [string]$var_export_file = $var_local + "\Disconnected" + $var_date + ".txt"
} else {
    [string]$var_export_file = $var_local + "\DisconnectedNICs" + ".txt"
}
#Check for VMware PS Module
$loaded = get-module VMware.VimAutomation.Core
    if(!$loaded) { 
        import-module VMware.VimAutomation.Core 
}

if(!$global:Defaultviserver.IsConnected){
    $vcenter = read-host -Prompt "vCenter (or host) IP/FQDN"
    connect-viserver -Server $vcenter
}


$var_NotConnected = @()

$var_VMs = Get-VM

$var_VMs | % {
    $var_Adapters = Get-NetworkAdapter -VM $_ 
        ForEach ($NIC in $var_Adapters){
            if(!$NIC.ConnectionState.StartConnected -or !$NIC.ConnectionState.Connected){
            $var_NICInfo = New-Object System.Object
            $var_NICInfo | Add-Member -type NoteProperty -Name VM -Value $NIC.Parent
            $var_NICInfo | Add-Member -type NoteProperty -Name AdapterName -Value $NIC.Name
            $var_NICInfo | Add-Member -type NoteProperty -Name Connected -Value $NIC.ConnectionState.Connected
            $var_NICInfo | Add-Member -type NoteProperty -Name ConnectOnPowerOn -Value $NIC.ConnectionState.StartConnected
            $var_NICInfo | Add-Member -type NoteProperty -Name AdapterType -Value $NIC.Type
            $var_NICInfo | Add-Member -type NoteProperty -Name MAC -Value $NIC.MacAddress
            $var_NICInfo | Add-Member -type NoteProperty -Name NetworkName -Value $NIC.NetworkName

            $var_NotConnected += $var_NICInfo
            }

        }
}

Write-Output $var_NotConnected 
Write-Host -ForegroundColor Cyan -BackgroundColor DarkRed "------------------------------------"
$var_export = Read-Host -Prompt "Export Results? (Y/N)"
    if ($var_export -match "Y"){
    $var_NotConnected | format-table -AutoSize | Out-File $var_export_file -Width 4096
        write-output "Results Exported to " $var_export_file
    }