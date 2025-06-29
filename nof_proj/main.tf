provider "azurerm" {
  features {
  }  
}

resource "azurerm_resource_group" "rg-nof" {
  name     = "nof-resources"
  location = var.location
}

resource "azurerm_virtual_network" "vnet-nof" {
  name                = "nof-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-nof.name
}

resource "azurerm_subnet" "subnet-nof" {
  name                 = "nof-subnet"
  resource_group_name  = azurerm_resource_group.rg-nof.name
  virtual_network_name = azurerm_virtual_network.vnet-nof.name
  address_prefixes     = ["10.0.1.0/24"]
}




resource "azurerm_linux_virtual_machine" "vm-nof" {
  name                  = "nof-vm"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg-nof.name
  network_interface_ids = [azurerm_network_interface.nic-nof.id]
  size                  = var.vm_size

  os_disk {
    name              = "nof-os-disk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_username = var.admin_username
  admin_password = var.admin_password

  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  computer_name = "nof-vm"
}


module "vm1" {
  source = "./modules/vm"
  vm_name = "vm1"
  nic_id  = azurerm_network_interface.nic1.id
  location = azurerm_resource_group.Group1.location
  resource_group_name = azurerm_resource_group.Group1.name
}

module "vm1" {
  source = "./modules/vm"
  vm_name = "vm2"
  nic_id  = azurerm_network_interface.nic1.id
  location = azurerm_resource_group.Group1.location
  resource_group_name = azurerm_resource_group.Group1.name
}

module "vm1" {
  source = "./modules/vm"
  vm_name = "vm3"
  nic_id  = azurerm_network_interface.nic1.id
  location = azurerm_resource_group.Group1.location
  resource_group_name = azurerm_resource_group.Group1.name
}




resource "time_sleep" "wait_for_ip" {
  create_duration = "120s"  # Wait for 30 seconds
}

output "vm_publteic_ip" {
  value = azurerm_public_ip.pip-nof.ip_address
  description = "Public IP address of the VM"
  depends_on = [time_sleep.wait_for_ip]
}

