$vHosts = get-vmhost

$vHosts | foreach {
$status = $_ | Get-VMHostService | Where {$_.Key -eq "TSM-SSH"}
	if ($status.Running){
		$var_sshEna = $_
		write-host $_.Name
		}
}
