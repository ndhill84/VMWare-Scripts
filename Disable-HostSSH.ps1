
Do{
$Do = Read-Host -Prompt "Turn off SSH on all hosts? (Y/N)"
} Until (($Do -match "Y") -or ($Do -match "N") -or ($Do -match "y") -or ($Do -match "n"))
    

if($Do -match "N"){
    Write-Host "Quitting..."
    
} 
if ($Do -Match "Y") {
    
    Write-Host "Shutting Down SSH..."
    Get-VMHost | ForEach {Stop-VMHostService -HostService ($_ | Get-VMHostService | Where {$_.Key -eq “TSM-SSH”})}

}
write-host "Complete."
