variable "vm_name" {
}

variable "rg" {
}

variable "subnet_id" {
}

variable "location" {
  default = "East US"
}

variable "vm_size" {
  default = "Standard_B1ms"
}

variable "admin_username" {
  default = "adminuser-nof"
}

variable "admin_password" {
  default = "Password123!"
}
