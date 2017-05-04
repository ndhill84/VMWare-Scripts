
$var_Installed = @();
$var_Installed += "VMware Products"

$var_AllVMs = Get-VM | ? { $_.ExtensionData.Summary.Config.Product.Name.Length -ne 0 }

#$var_AllVMs | % | ? { $_.ExtensionData.Summary.Config.Product.Name.Length -ne 0 }


    ForEach($VMs in $var_AllVMs)
    {
            $ProdInfo = New-Object System.Object
            $ProdInfo | Add-Member -type NoteProperty -Name 'VM Name' -Value $VMs.Name
            $ProdInfo | Add-Member -type NoteProperty -Name 'Product Name' -Value $VMs.extensiondata.summary.config.product.name
            $ProdInfo | Add-Member -type NoteProperty -Name 'Version' -Value $VMs.extensiondata.summary.config.product.Version
            $ProdInfo | Add-Member -type NoteProperty -Name 'Product URL' -Value $VMs.extensiondata.summary.config.product.producturl
            $ProdInfo | Add-Member -type NoteProperty -Name 'App URL' -Value $VMs.extensiondata.summary.config.product.appurl
            $ProdInfo | Add-Member -type NoteProperty -Name 'Managed By' -Value $VMs.extensiondata.summary.config.ManagedBy.ExtensionData
            $ProdInfo | Add-Member -type NoteProperty -Name 'Notes' -Value $VMs.extensiondata.Summary.Config.Annotations

            $var_Installed += $ProdInfo
}

#$var_AllVMs | | where { $_.Config.ManagedBy.ExtensionKey.Length -ne 0 }

Write-Output $var_Installed