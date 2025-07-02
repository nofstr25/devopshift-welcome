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
  rg = azurerm_resource_group.rg-nof.name
  location = azurerm_resource_group.rg-nof.location
  subnet_id = azurerm_subnet.subnet-nof.id
}

