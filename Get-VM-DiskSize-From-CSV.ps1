<#
.SYNOPSIS
   Pulls VM names from CSV files and gets the total size of all of their dard disks.
.DESCRIPTION
   Pulls VM names from CSV files. Gets the total size of all the VMDKs attached to all the VMs.
.NOTES
	File Name	: Get-VM-DiskSize-From-CSV.ps1
	Author		: Nick Hill - ndhill@gmail.com 
	Notes		: Place file in folder containing the CSV files.
.SYNTAX
	.\Get-VM-DiskSize-From-CSV.ps1
.EXAMPLE
    .\Get-VM-DiskSize-From-CSV.ps1
.COMPONENT
#>

if ($global:DefaultVIServers.IsConnected -eq $true) {
	write-host "You are currently connected to " -f "white" -nonewline; write-host $global:DefaultVIServers.Name -f "Magenta"
	write-host "I will proceed using this connection"
	} else {
	write-host "No active connection to a vCenter was found" -f "red"
	$vserver = read-host "Please enter vCenter server IP/FQDN"
	connect-viserver -server $vserver
}

$i=0
$files = $null
$vvms = $null
$disks = $null
$total = $null
$tb = $null
$local = $null

$local = get-location
write-host "Getting Files from " $local
$files = (Get-ChildItem *.csv)

write-host "Importing VM Names"

$files | foreach {	 
$vvms += (Get-Content $_.Name) -split ','
}

Write-Host "Gathering HD info..."
$vvms | foreach {
if(!($_ -eq "")){
$aa = Get-VM -Name $_
$disks += Get-HardDisk -VM $aa
$i++
}}

$disks | foreach {
	$total += $_.CapacityGB 
}
$tb = $total / 1024

$tb = [math]::Round($tb,2)

Echo $disks | sort FileName

write-host "----------------------"
write-host $disks.length "Disks Found on" $i "VMs"
write-host "Total GB: " -nonewline; write-host $total -f "white"
write-host "Total TB: " -nonewline; write-host $tb -f "white"
