# DEPLOIEMENT INFRA ...EN COURS DE DEVELOPPEMENT)
provider "azurerm" {
    features {
    }
}

# Création de la resource group "rg-alpha"
resource "azurerm_resource_group" "rglog" {
    name = "rg-alpha"
    location = "West Europe"
}

# Création du compte de stockage "disklog"
resource "azurerm_storage_account" "disklog" {
    name = "diskdelog"
    resource_group_name = azurerm_resource_group.rglog.name
    location = azurerm_resource_group.rglog.location
    account_tier = "Standard"
    account_replication_type = "LRS"
}

# Création du réseau virtuel "netwin"
resource "azurerm_virtual_network" "netlog" {
    name = "netwin"
    location = azurerm_resource_group.rglog.location
    resource_group_name = azurerm_resource_group.rglog.name
    address_space = [ "192.168.0.0/16" ]
}

# Création du sous-réseau virtuel subnetwin
resource "azurerm_subnet" "subnetlog" {
    name = "subnetwin"
    resource_group_name = azurerm_resource_group.rglog.name
    virtual_network_name = azurerm_virtual_network.netlog.name
    address_prefixes = [ "192.168.1.0/24" ] 
}

# Création de l'interface réseau "wincard"
resource "azurerm_network_interface" "logcard" {
    count = 2
    name = "wincard${count.index + 1}"
    location = azurerm_resource_group.rglog.location
    resource_group_name = azurerm_resource_group.rglog.name

    ip_configuration {
        name = "internalip"
        subnet_id = azurerm_subnet.subnetlog.id
        private_ip_address_allocation = "Dynamic"
    }
}

# Création de la machine virtuelle "WS-VM1"
resource "azurerm_windows_virtual_machine" "vmlog" {
    count = 2
    name = "WS-VM1${count.index + 1}"
    location = azurerm_resource_group.rglog.location
    resource_group_name = azurerm_resource_group.rglog.name
    size = "Standard_B2ms"
    admin_username = "prime"
    admin_password = "P@sswordP@ssword"
    network_interface_ids = [ 
        element(azurerm_network_interface.logcard.*.id, count.index)
     ]
    
    os_disk {
      caching = "ReadWrite"
      storage_account_type = "Standard_LRS"
    }     

    source_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer = "WindowsServer"
        sku = "2016-Datacenter"
        version = "latest"
    }
}

# Création de l'interface réseau "lincard"
resource "azurerm_network_interface" "loglincard" {
    name = "lincard"
    location = azurerm_resource_group.rglog.location
    resource_group_name = azurerm_resource_group.rglog.name

    ip_configuration {
        name = "internalip"
        subnet_id = azurerm_subnet.subnetlog.id
        private_ip_address_allocation = "Dynamic"
    }
}

# Création de la machine virtuelle "LX-VM2"
resource "azurerm_linux_virtual_machine" "vm2" {
  name                = "LX-VM2"
  location            = azurerm_resource_group.rglog.location
  resource_group_name = azurerm_resource_group.rglog.name
  size                = "Standard_B2ms"
  admin_username      = "Prime"
  admin_password      = "P@sswordP@ssword"
  network_interface_ids = [
    azurerm_network_interface.loglincard.id
  ]
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}


#Création d'une webapp
