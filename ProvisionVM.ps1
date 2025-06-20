# filepath: /azure-vm-provision/azure-vm-provision/scripts/ProvisionVM.ps1

# This script provisions a virtual desktop in Azure.

# Define parameters
param(
    [string]$resourceGroupName,
    [string]$location,
    [string]$vmName,
    [string]$adminUsername,
    [string]$adminPassword,
    [string]$vmSize = "Standard_DS1_v2"
)

# Login to Azure
Connect-AzAccount

# Create resource group
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Create virtual network
$vnet = New-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Location $location -Name "${vmName}VNet" -AddressPrefix "10.0.0.0/16"

# Create subnet
$subnet = Add-AzVirtualNetworkSubnetConfig -Name "${vmName}Subnet" -AddressPrefix "10.0.0.0/24" -VirtualNetwork $vnet
$vnet | Set-AzVirtualNetwork

# Create public IP address
$publicIp = New-AzPublicIpAddress -ResourceGroupName $resourceGroupName -Location $location -Name "${vmName}PublicIP" -AllocationMethod Dynamic

# Create network security group
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroupName -Location $location -Name "${vmName}NSG"

# Create network interface
$nic = New-AzNetworkInterface -ResourceGroupName $resourceGroupName -Location $location -Name "${vmName}NIC" -SubnetId $subnet.Id -PublicIpAddressId $publicIp.Id -NetworkSecurityGroupId $nsg.Id

# Create virtual machine configuration
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize -AvailabilitySetId $null -NetworkInterfaceId $nic.Id

# Set the operating system
$vmConfig = Set-AzVMOperatingSystem -VM $vmConfig -Windows -ComputerName $vmName -Credential (Get-Credential -UserName $adminUsername -Message "Enter the password for the VM") -ProvisionVMAgent -EnableAutoUpdate

# Set the source image
$vmConfig = Set-AzVMSourceImage -VM $vmConfig -PublisherName "MicrosoftWindowsDesktop" -Offer "windows-10" -Skus "19h2-pro" -Version "latest"

# Create the virtual machine
New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig

Write-Host "Virtual machine '$vmName' has been provisioned successfully in resource group '$resourceGroupName'."