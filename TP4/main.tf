# Fichier main.tf

#Configure the azure provider by adding the subscription id
provider "azurerm" {
  features {}
  subscription_id = "765266c6-9a23-4638-af32-dd1e32613047"
}

variable "resource_group_name" {
  description = "Azure Resource Group"
  default     = "ADDA84-CTP"
}

variable "location" {
  description = "Azure Region"
  default     = "francecentral"
}

variable "vm_name" {
  description = "Azure Virtual Machine Name"
  default = "devops-20220105"
}

variable "vm_size" {
  description = "Azure Virtual Machine Size"
  default     = "Standard_DS2_v2"
}

variable "network_name" {
  description = "Network"
  default = "network-tp4"
}

variable "azurerm_subnet" {
  description = "Subnet"
  default = "internal"
}

variable "user_admin" {
  description = "User Administrateur Virtual Machine"
  default     = "devops"
}

#Generate an SSH private key
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "public_key" {
  content  = tls_private_key.ssh.public_key_openssh
  filename = "ssh_public_key.pub"
}

output "private_key" {
  value     = tls_private_key.ssh.private_key_pem
  sensitive = true
}

#We need to access to the previously created subnet with a data block because it is 
#more secure to get all of the information about this component this way.
data "azurerm_subnet" "tp4" {
  name                 = "internal"
  virtual_network_name = var.network_name
  resource_group_name  = var.resource_group_name
}

#Generate id_rsa private key file
resource "null_resource" "generate_private_key" {
  provisioner "local-exec" {
    #Extract the private key from the ssh key that I just generated, and write it in 
    #the file called "id_rsa"
    command = "echo '${tls_private_key.ssh.private_key_pem}' > id_rsa"
  }
}

#Create a virtual machine
resource "azurerm_virtual_machine" "example" {
  name                  = "devops-20220105"
  resource_group_name   = var.resource_group_name
  location              = var.location
  vm_size               = "Standard_D2s_v3"
  network_interface_ids = [azurerm_network_interface.example.id]

  os_profile {
    computer_name  = "devops-20220105"
    admin_username = var.user_admin
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdisk-meliss"
    create_option     = "FromImage"
    caching           = "ReadWrite"
    managed_disk_type = "Standard_LRS"

  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.user_admin}/.ssh/authorized_keys"
      key_data = tls_private_key.ssh.public_key_openssh
    }
  }
}

#Create public ip adress
resource "azurerm_public_ip" "example" {
  name                = "public-ip-melis"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}

#Create network interface
resource "azurerm_network_interface" "example" {
  name                = "nic-melis"
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = "internal-ip-config-melis"
    #To get the subnet id we need to refer to the data block for subnet
    subnet_id                     = data.azurerm_subnet.tp4.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

