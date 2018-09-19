function SubGroupMembers ($SecGroup) {
    $subVMs = Get-NsxSecurityGroup -Name $SecGroup
    $subVMs
        if ($subVMs.dynamicMemberDefinition){
            if(($subVMs.dynamicMemberDefinition.dynamicSet.dynamicCriteria.key -like "VM.NAME") -and ($subVMs.dynamicMemberDefinition.dynamicSet.dynamicCriteria.criteria -like "starts_with")){
                $searchName = $subVMs.dynamicMemberDefinition.dynamicSet.dynamicCriteria.value + "*"
                $ActualVMs = get-vm -name $searchName
            }
        } else {
            $ActualVMs = $subVMs.member
        }
    
    return $ActualVMs
}

# Assign SecGroup Name Here
$SecGroup = Get-NsxSecurityGroup -Name "NameOfSecGroup"
$SubGroups = @()
$GroupVMs = @()
    $SecGroup.member | ForEach-Object{
        if($_.objectTypeName -notlike "VirtualMachine"){
            $Sub_SGs = New-Object psobject -Property @{
                Name = $_.Name;
                Description = $_.Description;
                ObjectId = $_.ObjectId;
            }
        $SubGroups += $Sub_SGs
        } else {
            $GroupVMs += $_
        }
    }
$AllSubVMs += $SubGroups | ForEach-Object {
    SubGroupMembers $_.name
}

$Complete_List = $groupVMs.Name
$Complete_List += $AllSubVMs.Name
$Complete_List