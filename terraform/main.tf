terraform {
  required_version = ">=0.12"
  
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {
    subscription_id = "${{ secrets.ARM_SUBSCRIPTION_ID }}"
    client_id       = "${{ secrets.ARM_CLIENT_ID }}"
    client_secret   = "${{ secrets.ARM_CLIENT_SECRET }}"
    tenant_id       = "${{ secrets.ARM_TENANT_ID }}"
  }
}

resource "azurerm_resource_group" "DatariskVM" {
 name     = var.resource_group_name
 location = var.location
 tags     = var.tags
}

resource "azurerm_virtual_network" "DatariskVM" {
 name                = "DatariskVM-vnet"
 address_space       = ["10.0.0.0/16"]
 location            = var.location
 resource_group_name = azurerm_resource_group.DatariskVM.name
 tags                = var.tags
}

resource "azurerm_subnet" "DatariskVM" {
 name                 = "DatariskVM-subnet"
 resource_group_name  = azurerm_resource_group.DatariskVM.name
 virtual_network_name = azurerm_virtual_network.DatariskVM.name
 address_prefixes       = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "DatariskVM" {
 name                         = "DatariskVM-public-ip"
 location                     = var.location
 resource_group_name          = azurerm_resource_group.DatariskVM.name
 allocation_method            = "Static"
 domain_name_label            = "mydomain-ssh"
 tags                         = var.tags
}

resource "azurerm_network_interface" "DatariskVM" {
 name                = "DatariskVM-nic"
 location            = var.location
 resource_group_name = azurerm_resource_group.DatariskVM.name

 ip_configuration {
   name                          = "IPConfiguration"
   subnet_id                     = azurerm_subnet.DatariskVM.id
   private_ip_address_allocation = "dynamic"
   public_ip_address_id          = azurerm_public_ip.DatariskVM.id
 }
 tags = var.tags
}

resource "azurerm_network_interface_security_group_association" "Datarisk" {
  network_interface_id      = azurerm_network_interface.DatariskVM.id
  network_security_group_id = azurerm_network_security_group.Datarisk.id
}

resource "azurerm_virtual_machine" "DatariskVM" {
 name                  = "DatariskVM"
 location              = var.location
 resource_group_name   = azurerm_resource_group.DatariskVM.name
 network_interface_ids = [azurerm_network_interface.DatariskVM.id]
 vm_size               = "Standard_DS1_v2"

 storage_image_reference {
   publisher = "Canonical"
   offer     = "UbuntuServer"
   sku       = "18.04-LTS"
   version   = "latest"
 }

 storage_os_disk {
   name              = "DatariskVM-osdisk"
   caching           = "ReadWrite"
   create_option     = "FromImage"
   managed_disk_type = "Standard_LRS"
 }

 os_profile {
   computer_name  = "DatariskVM"
   admin_username = var.admin_user
 }

 os_profile_linux_config {
   disable_password_authentication = false
 }

 tags = var.tags
}

resource "azurerm_network_security_group" "Datarisk" {
  name                = "datariskSG"
  location            = var.location
  resource_group_name = azurerm_resource_group.DatariskVM.name

  security_rule {
    name                       = "allow_ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
  tags = {
    environment = "dev"
  }
}
