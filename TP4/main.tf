# Configuration du fournisseur Azure
provider "azurerm" {
  features {}
}

# Création de la machine virtuelle
resource "azurerm_virtual_machine" "example" {
  name                  = "devops-20220105"
  location              = "francecentral"
  resource_group_name   = "ADDA84-CTP"
  vm_size               = "Standard_D2s_v3"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "devops-20220105"
    admin_username = "devops"
    admin_password = "YOUR_PASSWORD_HERE"  # Remplacez par votre mot de passe souhaité ou utilisez un secret plus sécurisé (ex: Azure Key Vault)
  }

  network_interface_ids = [
    azurerm_network_interface.example.id
  ]
}

# Création de l'interface réseau
resource "azurerm_network_interface" "example" {
  name                = "nic"
  location            = "francecentral"
  resource_group_name = "ADDA84-CTP"

  ip_configuration {
    name                          = "config"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Récupération de l'ID du sous-réseau
data "azurerm_subnet" "example" {
  name                 = "internal"
  virtual_network_name = "network-tp4"
  resource_group_name  = "ADDA84-CTP"
}

# Définition de l'adresse IP publique
resource "azurerm_public_ip" "example" {
  name                = "publicip"
  location            = "francecentral"
  resource_group_name = "ADDA84-CTP"
  allocation_method   = "Static"
}

# Association de l'adresse IP publique à l'interface réseau
resource "azurerm_public_ip_association" "example" {
  name                = "ipassociation"
  resource_group_name = "ADDA84-CTP"
  public_ip_address_id = azurerm_public_ip.example.id
  # Association à l'interface réseau
  network_interface_id = azurerm_network_interface.example.id
}

# Création du groupe de ressources
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

# Création du réseau virtuel
resource "azurerm_virtual_network" "example" {
  name                = var.network_name
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
}

# Création du sous-réseau
resource "azurerm_subnet" "example" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Création de la machine virtuelle
resource "azurerm_virtual_machine" "example" {
  name                = var.vm_name
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  vm_size             = "Standard_D2s_v3"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "example-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  os_profile {
    computer_name  = "devops"
    admin_username = "devops"
    custom_data    = filebase64("${path.module}/cloud-init.txt")
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/devops/.ssh/authorized_keys"
      key_data = file("~/.ssh/id_rsa.pub")
    }
  }

  network_interface {
    name                      = "example-nic"
    network_security_group_id = azurerm_network_security_group.example.id
    ip_configuration {
      name                          = "example-ip-config"
      subnet_id                     = azurerm_subnet.example.id
      private_ip_address_allocation = "Dynamic"
    }
  }
}

# Création du groupe de sécurité réseau
resource "azurerm_network_security_group" "example" {
  name                = "example-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = ["*"]
    destination_address_prefix = "*"
  }
}
