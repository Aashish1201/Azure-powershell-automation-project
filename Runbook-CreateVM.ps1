param (
    [string]$rgName = "automationRG",
    [string]$location = "EastUS",
    [string]$vmName = "automatedVM",
    [string]$adminUsername,
    [string]$adminPassword
)

try {
    # Connect to Azure with explicit subscription handling
    Disable-AzContextAutosave -Scope Process
    
    # Connect using managed identity
    $AzureContext = Connect-AzAccount -Identity
    
    # Get all available subscriptions
    $subscriptions = Get-AzSubscription
    
    if ($subscriptions.Count -eq 0) {
        throw "No subscriptions found for this managed identity"
    }
    
    # Select the first subscription or specify by name/ID
    $subscriptionId = $subscriptions[0].Id
    Set-AzContext -SubscriptionId $subscriptionId
    
    Write-Output "Successfully connected to subscription: $($subscriptions[0].Name)"

    # Create credential object
    $securePassword = ConvertTo-SecureString $adminPassword -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential ($adminUsername, $securePassword)

    # Check if resource group exists, create if not
    if (-not (Get-AzResourceGroup -Name $rgName -ErrorAction SilentlyContinue)) {
        Write-Output "Creating resource group $rgName in $location"
        New-AzResourceGroup -Name $rgName -Location $location
    }
    else {
        Write-Output "Using existing resource group $rgName"
    }

    # Create the VM
    Write-Output "Creating VM $vmName in resource group $rgName"
    $vmParams = @{
        ResourceGroupName = $rgName
        Name              = $vmName
        Location          = $location
        Credential        = $cred
        Image             = "Ubuntu2204"
        OpenPorts         = 22
    }
    
    $vm = New-AzVM @vmParams
    
    Write-Output "Successfully created VM $vmName"
    Write-Output "Public IP: $($vm.NetworkProfile.NetworkInterfaces[0].Id)"
}
catch {
    Write-Error "Error occurred: $_"
    throw
}
