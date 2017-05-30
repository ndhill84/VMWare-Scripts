if (!$global:DefaultVIServer)
    {
        $vcServer = Read-Host "vCenter Server IP/FQDN"
        connect-viserver -Server $vcServer
    }

$vmName = Read-Host "VM Name"
try {
    $vm = get-vm -name $vmName
}
catch {
    write-host "Couldn't find VM" $vm "Check the name."
	exit
}
$nic = $vm | Get-NetworkAdapter

Set-NetworkAdapter -NetworkAdapter $nic -Connected:$false

Set-NetworkAdapter -NetworkAdapter $nic -Connected:$true
