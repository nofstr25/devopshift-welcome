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



module "vm1" {
  source = "./modules/vm"
  vm_name = "vm3"
  location = azurerm_resource_group.Group1.location
  rg = azurerm_resource_group.Group1.name
}




resource "time_sleep" "wait_for_ip" {
  create_duration = "120s"  # Wait for 30 seconds
}

output "vm_publteic_ip" {
  value = azurerm_public_ip.pip-nof.ip_address
  description = "Public IP address of the VM"
  depends_on = [time_sleep.wait_for_ip]
}

