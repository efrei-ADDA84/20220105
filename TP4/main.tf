# Fichier main.tf

# Configurez le fournisseur Azure
provider "azurerm" {
  features {}
  subscription_id = "765266c6-9a23-4638-af32-dd1e32613047"
}

# Définissez les variables
variable "azure_subscription_id" {
  description = "Azure Subscription ID"
}

variable "resource_group_name" {
  description = "ADDA84-CTP"
}

variable "location" {
  description = "Azure Region"
  default     = "francecentral"
}

variable "vm_name" {
  description = "devops-20220105"
}

variable "vm_size" {
  description = "Azure Virtual Machine Size"
  default     = "Standard_DS2_v2"
}

# Créez le groupe de ressources
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

# Créez le réseau virtuel
resource "azurerm_virtual_network" "example" {
  name                = "network-tp4"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
}

# Créez le sous-réseau
resource "azurerm_subnet" "example" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.0.0/24"]
}
resource "azurerm_storage_account" "example" {
  name                     = "mystorageaccount123"  
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
# Créez la machine virtuelle
resource "azurerm_virtual_machine" "example" {
  name                  = "devops-20220105"
  resource_group_name   = azurerm_resource_group.example.name
  location              = azurerm_resource_group.example.location
  vm_size               = "Standard_D2s_v3"
  network_interface_ids = [azurerm_network_interface.example.id]

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdisk"
    create_option     = "FromImage"
    caching           = "ReadWrite"
    managed_disk_type = "Standard_LRS"
    
  }

  os_profile {
    computer_name  = "devops-20220105"
    admin_username = "devops"
    admin_password = "12345"  # Set your own admin password here
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.example.primary_blob_endpoint
  }
}


# Créez l'adresse IP publique
resource "azurerm_public_ip" "example" {
  name                = "public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
}

# Créez la carte réseau
resource "azurerm_network_interface" "example" {
  name                      = "nic"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.example.name
  ip_configuration {
    name                          = "internal-ip-config"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

