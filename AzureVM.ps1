##Defining the variables

$resourceGroup = "pshell-automation-RG"
$location = "eastus"
$vmName = "pshell-VM"

$cred = Get-Credential

## Create the resource group (id it does not exist)

New-AzResourceGroup -Name $resourceGroup -Location $location

##Create a Ubuntu VM

New-AzVM `
   -ResourceGroupName $resourceGroup `
   -Name $vmName `
   -Location $location `
   -Credential $cred `
   -Image "Ubuntu2204" `
   -OpenPorts 22 `



