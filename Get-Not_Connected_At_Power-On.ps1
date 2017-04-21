<#
.SYNOPSIS
  Pulls all Network Adapters not set to Connect on Power-On  
.OUTPUTS
    VM, AdapterName, AdapterType, MAC, NetworkName of NICs not set to Connect on Powerr-On. Option to export results to txt file.
.NOTES
    Version:        1.0
    Author:         Nick Hill
    Creation Date:  04/20/2017
    Purpose/Change: Initial script development
.EXAMPLE
    c:\>.\Get-Not_Connected_At_Power-On.ps1
#>

#Check for VMware PS Module
$loaded = get-module VMware.VimAutomation.Core
    if(!$loaded) { 
        import-module VMware.VimAutomation.Core 
}

if(!$global:Defaultviserver.IsConnected){
    $vcenter = read-host -Prompt "vCenter IP/FQDN"
    connect-viserver -Server $vcenter
}


$var_NotConnected = @()

$var_VMs = Get-VM

$var_VMs | % {
    $var_Adapters = Get-NetworkAdapter -VM $_ 
        ForEach ($NIC in $var_Adapters){
            if(!$NIC.ConnectionState.StartConnected){
            $var_NICInfo = New-Object System.Object
            $var_NICInfo | Add-Member -type NoteProperty -Name VM -Value $NIC.Parent
            $var_NICInfo | Add-Member -type NoteProperty -Name AdapterName -Value $NIC.Name
            $var_NICInfo | Add-Member -type NoteProperty -Name AdapterType -Value $NIC.Type
            $var_NICInfo | Add-Member -type NoteProperty -Name MAC -Value $NIC.MacAddress
            $var_NICInfo | Add-Member -type NoteProperty -Name NetworkName -Value $NIC.NetworkName
            $var_NICInfo | Add-Member -type NoteProperty -Name ConnectOnPowerOn -Value $NIC.ConnectionState.StartConnected

            $var_NotConnected += $var_NICInfo
            }

        }
}

Write-Output $var_NotConnected 
Write-Host -ForegroundColor Cyan -BackgroundColor DarkRed "------------------------------------"
$var_export = Read-Host -Prompt "Export Results? (Y/N)"
    if ($var_export -match "Y"){
    [string]$var_local = Get-Location
    [string]$var_export_file = $var_local + "\output.txt"
    $var_NotConnected | format-table | Out-File $var_export_file
        write-output "Results Exported to " $var_export_file
    }