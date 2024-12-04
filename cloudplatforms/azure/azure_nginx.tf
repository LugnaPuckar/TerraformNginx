# 1. Define provider
provider "azurerm" {
  features {}
  subscription_id = trimspace(file("../../cloud_secrets/azure_subscription_id.txt"))
}

# 2. Variables (optional but useful for reuse)
variable "resource_group_name" {
  default = "test-vm-rg4"
}

variable "location" {
  default = "northeurope"
}

# 3. Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# 4. Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "test-vm-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

# 5. Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "test-vm-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# 5.1. Associate NSG with Subnet
resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# 6. Public IP Address (optional, for internet access)
resource "azurerm_public_ip" "public_ip" {
  name                = "test-vm-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

# 7. Network Interface
resource "azurerm_network_interface" "nic" {
  name                = "test-vm-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

# 8. Network Security Group (NSG) - Allows SSH (port 22) and HTTP (port 80)
resource "azurerm_network_security_group" "nsg" {
  name                = "test-vm-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                  = "Tcp"
    source_port_range         = "*"
    destination_port_range    = "22"
    source_address_prefix     = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                  = "Tcp"
    source_port_range         = "*"
    destination_port_range    = "80"
    source_address_prefix     = "*"
    destination_address_prefix = "*"
  }
}

# 9. Virtual Machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "testVM"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = "Standard_B1s"
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.nic.id]

  # SSH Key Configuration
  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  # OS Disk Configuration
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Image Reference: Using the specific version of Ubuntu Server 24.04 LTS
  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"  # Can specify an exact version like "24.04.202411030" if needed
  }

  # Custom Data: Install Nginx
  # custom_data = base64encode(file("../../customData/install_nginx.sh"))

  # Custom Data: Install Nginx bash script
  custom_data = base64encode(<<-EOF
                #!/bin/bash
                apt update
                apt install nginx -y
                systemctl enable nginx
                systemctl start nginx
                EOF
  )

  tags = {
    Environment = "Development"
  }
}


# 10. Output the Public IP Address
output "vm_public_ip" {
  value = azurerm_public_ip.public_ip.ip_address
}
