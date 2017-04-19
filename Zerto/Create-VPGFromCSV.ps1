param (
[parameter(Mandatory = $true, HelpMessage="New VPG Name")][alias("-vpg","v")][string[]]$vpgName,
[parameter(Mandatory = $true, HelpMessage="CVS file of VMs to go in VPG")][alias("-file","f")][string[]]$unProtectedVMsCSVFile
	)
	while(!(Test-Path $unProtectedVMsCSVFile)){
	Write-host "File is missing or invalid path"
	$unProtectedVMsCSVFile = read-host "Enter file with VM names"
}



#Parameters Section
$strZVMIP = "10.10.10.10"
$strZVMPort = "9669"
$strZVMUser = ""
$strZVMPw = ""
$sourceSiteName = "Site-1"
$targetSiteName = "DR-Trarget"
$targetDataStoreName = "Datastore01"
$BASEURL = "https://" + $strZVMIP + ":"+$strZVMPort+"/v1/" #base URL for all APIs
##Function Definitions
#Get a site identifier by invoking Zerto APIs, given a Zerto API session and a sitename:
function getSiteIdentifierByName ($sessionHeader, $siteName){
$url = $BASEURL + "virtualizationsites"
$response = Invoke-RestMethod -Uri $url -Headers $zertoSessionHeader -ContentType "application/xml"
ForEach ($site in $response.ArrayOfVirtualizationSiteApi.VirtualizationSiteApi) {
if ($site.VirtualizationSiteName -eq $siteName){
return $site.SiteIdentifier
}
}
}
#Get a storage identifier by invoking Zerto APIs, given a Zerto Virtual Replication API session and a storage name:
function getDatastoreIdentifierByName ($sessionHeader, $siteIdentfier, $datastoreName){
$url = $BASEURL + "virtualizationsites/"+$siteIdentfier + "/datastores"
$response = Invoke-RestMethod -Uri $url -Headers $zertoSessionHeader -ContentType "application/xml"
ForEach ($datastore in $response.ArrayOfDatastoreNativeApi.DatastoreNativeApi) {
if ($datastore.DatastoreName -eq $datastoreName){
return $datastore.DatastoreIdentifier
}
}
}

#Get unprotected VM identifiers by invoking Zerto APIs, given a Zerto API session, a site identifier, and a list of VMs to add to the VPG:
function getUnprotectedVMsIdentifiers($sessionHeader, $siteIdentfier, $VMNames){
$url = $BASEURL + "virtualizationsites/"+$siteIdentfier + "/vms"
$unprotectedVMsIdentifiers = @()
$response = Invoke-RestMethod -Uri $url -Headers $zertoSessionHeader -ContentType "application/xml"
ForEach ($vm in $response.ArrayOfVmNativeApi.VmNativeApi) {
if ($VMNames.IndexOf($vm.VmName) -gt -1){
$unprotectedVMsIdentifiers+=($vm.VmIdentifier)
}
}
return $unprotectedVMsIdentifiers
}
#Authenticate with Zerto APIs: create a Zerto API session and return it, to be used in other APIs
function getZertoXSession (){
#Authenticate with Zerto APIs:
$xZertoSessionURI = $BASEURL + "session/add"
write-host $xZertoSessionURI
$authInfo = ("{0}:{1}" -f $strZVMUser,$strZVMPw)
write-host $authInfo 
write-host $strZVMUser $strZVMPw
$authInfo = [System.Text.Encoding]::UTF8.GetBytes($authInfo)
write-host $authInfo
$authInfo = [System.Convert]::ToBase64String($authInfo)
write-host $authInfo
$headers1 = @{Authorization=("Basic {0}" -f $authInfo)}
write-host $headers
$body = '{"AuthenticationMethod": "1"}'
$contentType = "application/json"
$xZertoSessionResponse = Invoke-WebRequest -Uri $xZertoSessionURI -Headers $headers1 -Method POST -Body $body -ContentType $contentType
write-host $xZertoSessionResponse
#Extract x-zerto-session from the response and add it to the actual API:
$xZertoSession = $xZertoSessionResponse.headers.get_item("x-zerto-session")
write-host $xZertoSession

return $xZertoSession
}
#Build VM elements to be added to the VPGs API, based on a list of VM identifiers
function buildVMsElement ($VMs) {
$response = "<VmsIdentifiers>"
ForEach ($vm in $VMs) {
$response+="<string xmlns="+'"http://schemas.microsoft.com/2003/10/Serialization/Arrays"'+">"+$vm+"</string>"
}
$response += "</VmsIdentifiers>"
return $response
}

$xZertoSession = getZertoXSession
$zertoSessionHeader = @{"x-zerto-session"=$xZertoSession}
$sourceSiteIdentifier = getSiteIdentifierByName $zertoSessionHeader $sourceSiteName
$targetSiteIdentifier = getSiteIdentifierByName $zertoSessionHeader $targetSiteName
$dataStoreIdentifier = getDatastoreIdentifierByName $zertoSessionHeader $targetSiteIdentifier $targetDataStoreName
$unprotectedVMNames = Get-Content $unProtectedVMsCSVFile | %{$_.Split(",")}
$vmsIdentifiers = getUnprotectedVMsIdentifiers $zertoSessionHeader $sourceSiteIdentifier $unprotectedVMNames
$vmsIdentifiersElement = buildVMsElement $vmsIdentifiers
#Create the URL and body of the VPGs request:
$createVPGUrl = $BASEURL+"vpgs"
$vpgsRequestBody = "<VpgCreateDataApi xmlns="+'"http://schemas.zerto.com/zvm/api"'+">"+"<DatastoreIdentifier>"+$dataStoreIdentifier +"</DatastoreIdentifier><SourceSiteIdentifier>"+$sourceSiteIdentifier+"</SourceSiteIdentifier><TargetSiteIdentifier>"+$targetSiteIdentifier+ "</TargetSiteIdentifier>"+$vmsIdentifiersElement+"<VpgName>"+$vpgName+"</VpgName></VpgCreateDataApi>"
#Invoke the Zerto API:
Invoke-RestMethod -Uri $createVPGUrl -Headers $zertoSessionHeader -Body $vpgsRequestBody -ContentType "application/xml" -method POST
##End of script
