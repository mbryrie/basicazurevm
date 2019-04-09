$RGName = "MR-SimpleVM"
$NSGName = "vm01-nsg"
$Location = "CanadaCentral"
$VNETName = "MR-SimpleVM-vnet"
$NICName = "vm01-nic01"
$NICIPConfigurationName = "ipconfig1"
$PIPName = "vm01-ip"
$PIPConfiguration = "Dynamic"
$VNETAddressPrefix = "10.1.0.0/16"
$VNETSubnetName = "default"
$VNETSubnetPrefix = "10.1.0.0/24"
$VMSize = "Standard_DS1_v2"
$VMName = "vm01"
$VMPublisherName = "MicrosoftWindowsServer"
$VMOffer = "WindowsServer"
$VMSKU = "2019-Datacenter"
$credentials = Get-Credential -Message "Please enter the username and password for the VM"

$RG = New-AzureRmResourceGroup -Name $RGName -Location $Location

$NSG = New-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $RG.ResourceGroupName -Location $RG.Location -SecurityRules `
@(New-AzureRmNetworkSecurityRuleConfig -Name "RDP" -Description "RDP" -Protocol Tcp -SourcePortRange * -DestinationPortRange 3389 -Access Allow -Priority 300 `
-Direction Inbound -SourceAddressPrefix * -DestinationAddressPrefix *)

$PIP = New-AzureRmPublicIpAddress -Name $PIPName -Location $Location -ResourceGroupName $RG.ResourceGroupName -AllocationMethod $PIPConfiguration

$VNETSubnetConfig = New-AzureRmVirtualNetworkSubnetConfig -Name $VNETSubnetName -AddressPrefix $VNETSubnetPrefix 

$VNET = New-AzureRmVirtualNetwork -Name $VNETName -ResourceGroupName $RG.ResourceGroupName -Location $RG.Location -AddressPrefix $VNETAddressPrefix `
 -Subnet $VNETSubnetConfig

$NICConfiguration = New-AzureRmNetworkInterfaceIpConfig -Name $NICIPConfigurationName -PublicIpAddress $PIP -Subnet $VNET.Subnets[0] 

$NIC = New-AzureRmNetworkInterface -Name $NICName -ResourceGroupName $RG.ResourceGroupName -Location $RG.Location -IpConfiguration $NICConfiguration `
-NetworkSecurityGroup $NSG

$VM = New-AzureRmVMConfig -VMName "vm01" -VMSize $VMSize
$VM = Set-AzureRmVMOperatingSystem -VM $VM -Windows -ComputerName $VMName -ProvisionVMAgent -EnableAutoUpdate -Credential $credentials
$VM = Add-AzureRmVMNetworkInterface -VM $VM -NetworkInterface $NIC
$VM = Set-AzureRmVMSourceImage -VM $VM -PublisherName $VMPublisherName -Offer $VMOffer -Skus $VMSKU -Version "latest"

New-AzureRmVM -ResourceGroupName $RG.ResourceGroupName -Location $RG.Location -VM $VM
