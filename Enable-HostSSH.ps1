
Do{
$Do = Read-Host -Prompt "Turn ON SSH on all hosts? (Y/N)"
} Until (($Do -match "Y") -or ($Do -match "N") -or ($Do -match "y") -or ($Do -match "n"))
    

if($Do -match "N"){
    Write-Host "Quitting..."
    
} 
if ($Do -Match "Y") {
    
    Write-Host "Doing Something"
    Get-VMHost | ForEach {Start-VMHostService -HostService ($_ | Get-VMHostService | Where {$_.Key -eq “TSM-SSH”})}

}
    
