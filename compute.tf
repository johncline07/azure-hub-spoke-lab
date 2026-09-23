resource "azurerm_linux_virtual_machine" "spoke1_vm" {
  name                = "vm-spoke1"
  resource_group_name = azurerm_resource_group.hub_spoke.name
  location            = azurerm_resource_group.hub_spoke.location
  size                = "Standard_D2alds_v7"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.spoke1_vm.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.vm_ssh_public_key
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
  size                = "Standard_D2alds_v7"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.spoke2_vm.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.vm_ssh_public_key
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

resource "azurerm_linux_virtual_machine" "jumpbox_vm" {
  name                = "jumpbox-vm"
  resource_group_name = azurerm_resource_group.hub_spoke.name
  location            = azurerm_resource_group.hub_spoke.location
  size                = "Standard_D2alds_v7"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.jumpbox_vm.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.vm_ssh_public_key
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


resource "azurerm_linux_virtual_machine" "snet_nva" {
  name                = "nva-vm"
  resource_group_name = azurerm_resource_group.hub_spoke.name
  location            = azurerm_resource_group.hub_spoke.location
  size                = "Standard_D2alds_v7"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.hub_nva.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.vm_ssh_public_key
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

resource "azurerm_network_interface" "jumpbox_vm" {
  name                = "nic-jumpbox-vm"
  location            = azurerm_resource_group.hub_spoke.location
  resource_group_name = azurerm_resource_group.hub_spoke.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.hub_services.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jumpbox.id
  }
}

resource "azurerm_network_interface" "hub_nva" {
  name                = "nic-nva-vm"
  location            = azurerm_resource_group.hub_spoke.location
  resource_group_name = azurerm_resource_group.hub_spoke.name

  ip_forwarding_enabled = true

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet-hub-nva.id
    private_ip_address            = "10.0.2.4"
    private_ip_address_allocation = "Static"
  }

}