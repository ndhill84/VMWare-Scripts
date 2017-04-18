if (!$global:DefaultVIServer)
    {
        $vcServer = Read-Host "vCenter Server IP/FQDN"
        connect-viserver -Server $vcServer
    }

$vmName = Read-Host "VM Name"
$vm = get-vm -name $vmName
$nic = $vm | Get-NetworkAdapter

Set-NetworkAdapter -NetworkAdapter $nic -Connected:$false

Set-NetworkAdapter -NetworkAdapter $nic -Connected:$true