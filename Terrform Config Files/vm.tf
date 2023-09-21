resource "azurerm_resource_group" "rg" { 
  name     = "Terraform-rg"
  location = "east us"
}

# Create virtual network
resource "azurerm_virtual_network" "myNetwork" {
  name                = "myVnet"
  address_space       = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.rg.name
  location            	= azurerm_resource_group.rg.location
}

# Create subnet
resource "azurerm_subnet" "mySubnet" {
  name                 = "mySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.myNetwork.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "myVMPublicIP" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myNSG" {
  name                = "myNetworkSecurityGroup"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  security_rule {
    name                       	= "SSH"
    priority                   	= 1001
    direction                  	= "Inbound"
    access                     	= "Allow"
    protocol                   	= "Tcp"
    source_port_range       	= "*"
    destination_port_range	= "22"
    source_address_prefix  	= "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       	= "HTTP"
    priority                   	= 1000
    direction                  	= "Inbound"
    access                     	= "Allow"
    protocol                   	= "Tcp"
    source_port_range          = "*"
    destination_port_range 	 = "80"
    source_address_prefix    = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "myNIC" {
  name                = "myNIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          	= "myNIC"
    subnet_id                     	= azurerm_subnet.mySubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myVMPublicIP.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      	     = azurerm_network_interface.myNIC.id
  network_security_group_id = azurerm_network_security_group.myNSG.id
}

# Create (and display) an SSH key
resource "tls_private_key" "mySSH" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save SSH to Login to Remote VM.
resource "local_file" "private_key" {
  content         = tls_private_key.mySSH.private_key_pem
  filename        = "azure.pem"
  file_permission = "0600"
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "my_terraform_vm" {
  name                  = "myVM"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.myNIC.id]
  size                  = "Standard_DS1_v2"
  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  computer_name                   = "myvm"
  admin_username                  = "azureuser"
  admin_password                  = "Password@123"
  disable_password_authentication = false
  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.mySSH.public_key_openssh
  }
  depends_on = [
    azurerm_network_interface_security_group_association.example
  ]
}
output azureVM_public_ip {
  value = azurerm_public_ip.myVMPublicIP.ip_address
  depends_on = [
    azurerm_linux_virtual_machine.my_terraform_vm
  ]
}
