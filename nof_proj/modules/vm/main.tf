
resource "azurerm_public_ip" "pip-nof" {
  name                = "${var.vm_name}-pip"
  location            = var.location
  resource_group_name = var.rg
  allocation_method   = "Dynamic"  # Dynamic IP allocation for Basic SKU
  sku = "Basic"  
}

resource "azurerm_network_interface" "nic-nof" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.rg

  ip_configuration {
    name                          = "${var.vm_name}-ip"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip-nof.id
  }
}
resource "azurerm_linux_virtual_machine" "vm-nof" {
  name                  = var.vm_name
  location              = var.location
  resource_group_name   = var.rg
  network_interface_ids = [azurerm_network_interface.nic-nof.id]
  size                  = var.vm_size

  os_disk {
    name              = "${var.vm_name}-disk"
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

resource "time_sleep" "wait_for_ip" {
  create_duration = "120s"  # Wait for 30 seconds
}

output "vm_publteic_ip" {
  value = azurerm_public_ip.pip-nof.ip_address
  description = "Public IP address of the VM"
  depends_on = [time_sleep.wait_for_ip]
}
