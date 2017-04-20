$LocalVMs = @();
$AllVMs = Get-VM

ForEach ($vm in $AllVMs) {
    $var_VM_DSID = $vm.DatastoreIdList
    $var_VM_Name = $vm.Name
<#  
Write-Host -ForegroundColor White "----------------------------"
    Write-Host -ForegroundColor Cyan -NoNewline "Datastore IDs: " 
    Write-Host $var_VM_DSID
    Write-Host -ForegroundColor Cyan -NoNewLine "VM Name: " 
    Write-Host $var_VM_Name
    Write-Host -ForegroundColor White "----------------------------"
    
    #>

    $var_VM_DSID | ForEach {
        $var_Datastore = Get-Datastore -id $_

        if ($var_Datastore.ExtensionData.Summary.MultipleHostAccess -eq $false){
            $var_LocalInfo = New-Object System.Object
            $var_LocalInfo | Add-Member -type NoteProperty -Name VM -Value $var_VM_Name
            $var_LocalInfo | Add-Member -type NoteProperty -Name DataStore -Value $var_Datastore.Name

            $LocalVMs += $var_LocalInfo

    }
}

} 

Write-Output $LocalVMs
