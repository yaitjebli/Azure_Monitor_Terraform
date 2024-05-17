#DEPLOIEMENT INFRA ...EN COURS DE DEVELOPPEMENT)
provider "azurerm" {
    features {
    }
}


resource "azurerm_resource_group" "rglog" {
    name = "rg-alpha"
    location = "West Europe"
}


resource "azurerm_storage_account" "disklog" {
    name = "diskdelog"
    resource_group_name = azurerm_resource_group.rglog.name
    location = azurerm_resource_group.rglog.location
    account_tier = "Standard"
    account_replication_type = "LRS"
}


resource "azurerm_virtual_network" "netlog" {
    name = "netwin"
    location = azurerm_resource_group.rglog.location
    resource_group_name = azurerm_resource_group.rglog.name
    address_space = [ "192.168.0.0/16" ]
}


resource "azurerm_subnet" "subnetlog" {
    name = "subnetwin"
    resource_group_name = azurerm_resource_group.rglog.name
    virtual_network_name = azurerm_virtual_network.netlog.name
    address_prefixes = [ "192.168.1.0/24" ] 
}


resource "azurerm_network_interface" "logcard" {
    name = "wincard"
    location = azurerm_resource_group.rglog.location
    resource_group_name = azurerm_resource_group.rglog.name

    ip_configuration {
        name = "internalip"
        subnet_id = azurerm_subnet.subnetlog.id
        private_ip_address_allocation = "Dynamic"
    }
}


resource "azurerm_windows_virtual_machine" "vmlog" {
    name = "WS-VM1"
    location = azurerm_resource_group.rglog.location
    resource_group_name = azurerm_resource_group.rglog.name
    size = "Standard_B2ms"
    admin_username = "prime"
    admin_password = "P@sswordP@ssword"
    network_interface_ids = [ 
        azurerm_network_interface.logcard.id
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