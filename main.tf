terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "hub_spoke" {
  name     = "rg-hub-spoke-lab"
  location = "East US"
}

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.hub_spoke.location
  resource_group_name = azurerm_resource_group.hub_spoke.name
}

resource "azurerm_subnet" "hub_services" {
  name                 = "snet-hub-services"
  resource_group_name  = azurerm_resource_group.hub_spoke.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_virtual_network" "spoke1" {
  name                = "vnet-spoke1"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.hub_spoke.location
  resource_group_name = azurerm_resource_group.hub_spoke.name
}

resource "azurerm_subnet" "spoke1_workload" {
  name                 = "snet-spoke1-workload"
  resource_group_name  = azurerm_resource_group.hub_spoke.name
  virtual_network_name = azurerm_virtual_network.spoke1.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_virtual_network" "spoke2" {
  name                = "vnet-spoke2"
  address_space       = ["10.2.0.0/16"]
  location            = azurerm_resource_group.hub_spoke.location
  resource_group_name = azurerm_resource_group.hub_spoke.name
}

resource "azurerm_subnet" "spoke2_workload" {
  name                 = "snet-spoke2-workload"
  resource_group_name  = azurerm_resource_group.hub_spoke.name
  virtual_network_name = azurerm_virtual_network.spoke2.name
  address_prefixes     = ["10.2.1.0/24"]
}

resource "azurerm_virtual_network_peering" "hub_to_spoke1" {
  name                      = "peer-hub-to-spoke1"
  resource_group_name       = azurerm_resource_group.hub_spoke.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke1.id
}

resource "azurerm_virtual_network_peering" "spoke1_to_hub" {
  name                      = "peer-spoke1-to-hub"
  resource_group_name       = azurerm_resource_group.hub_spoke.name
  virtual_network_name      = azurerm_virtual_network.spoke1.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
}

resource "azurerm_virtual_network_peering" "hub_to_spoke2" {
  name                      = "peer-hub-to-spoke2"
  resource_group_name       = azurerm_resource_group.hub_spoke.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke2.id
}

resource "azurerm_virtual_network_peering" "spoke2_to_hub" {
  name                      = "peer-spoke2-to-hub"
  resource_group_name       = azurerm_resource_group.hub_spoke.name
  virtual_network_name      = azurerm_virtual_network.spoke2.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
}

resource "azurerm_network_security_group" "spoke1" {
  name                = "nsg-spoke1-workload"
  location            = azurerm_resource_group.hub_spoke.location
  resource_group_name = azurerm_resource_group.hub_spoke.name
}

resource "azurerm_subnet_network_security_group_association" "spoke1" {
  subnet_id                 = azurerm_subnet.spoke1_workload.id
  network_security_group_id = azurerm_network_security_group.spoke1.id
}

resource "azurerm_network_security_group" "spoke2" {
  name                = "nsg-spoke2-workload"
  location            = azurerm_resource_group.hub_spoke.location
  resource_group_name = azurerm_resource_group.hub_spoke.name
}

resource "azurerm_subnet_network_security_group_association" "spoke2" {
  subnet_id                 = azurerm_subnet.spoke2_workload.id
  network_security_group_id = azurerm_network_security_group.spoke2.id
}

resource "azurerm_network_interface" "spoke1_vm" {
  name                = "nic-spoke1-vm"
  location            = azurerm_resource_group.hub_spoke.location
  resource_group_name = azurerm_resource_group.hub_spoke.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.spoke1_workload.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "spoke2_vm" {
  name                = "nic-spoke2-vm"
  location            = azurerm_resource_group.hub_spoke.location
  resource_group_name = azurerm_resource_group.hub_spoke.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.spoke2_workload.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "spoke1_vm" {
  name                = "vm-spoke1"
  resource_group_name = azurerm_resource_group.hub_spoke.name
  location            = azurerm_resource_group.hub_spoke.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.spoke1_vm.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("/home/clinej/.ssh/id_ed25519.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

resource "azurerm_linux_virtual_machine" "spoke2_vm" {
  name                = "vm-spoke2"
  resource_group_name = azurerm_resource_group.hub_spoke.name
  location            = azurerm_resource_group.hub_spoke.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.spoke2_vm.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("/home/clinej/.ssh/id_ed25519.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}