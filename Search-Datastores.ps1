param (
[parameter(Mandatory=$true, HelpMessage="Datstore(s) Name (Can use WildCard)")]$datastore,
[parameter(Mandatory=$false, HelpMessage="File Search Criteria (*.iso is default)")][String]$search=$null
	)

$ISO = @()
$var_AllDS = Get-Datastore -Name "MT_DS_VOL*"

$var_AllDS | % { New-PSDrive -Name $_.Name -PSProvider VimDatastore -Root "" }

    ForEach-Object ($DS in $var_AllDS) {

        [string]$PSLocation = $DS.Name + ":\"
        Set-Location $PSLocation
        if(!search){
            $ISOs += Get-ChildItem -Recurse *.iso
        } else {
            $ISOs += Get-ChildItem -Recurse $search
        }
    }

$ISOs | select Name, DatastoreFullPath, Datastore | ft -AutoSize