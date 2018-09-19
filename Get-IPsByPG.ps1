$DomainVMs = get-vm | where{$_.extensiondata.Network.value -like "dvportgroup-104"}
$DomIPs = @()
$DomainVMs | foreach{
    $newVM = New-Object psobject -Property @{
        Name = $_.Name;
        IP1 = $_.Guest.IPAddress[0]
    }
    $DomIPs += $newVM
}
$DomIPs
