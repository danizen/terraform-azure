# Configure the Azure provider
terraform {
  required_version = ">= 1.1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }
  backend "azurerm" {
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.region_name

  tags = {
    Environment = var.environment
    Team        = var.team
  }
}

module "vnet" {
  source              = "Azure/vnet/azurerm"
  version             = "2.7.0"
  resource_group_name = azurerm_resource_group.rg.name
  vnet_name           = each.key
  vnet_location       = each.value.location
  address_space       = each.value.address_space
  subnet_prefixes     = each.value.subnet_prefixes
  subnet_names        = ["subnet-app", "subnet-db"]

  tags = {
    Environment = var.environment
    Team        = var.team
  }

  depends_on = [azurerm_resource_group.rg]

  for_each = {
    vnet-danizen-1 = {
      location        = "eastus2"
      address_space   = ["10.0.0.0/16"]
      subnet_prefixes = ["10.0.1.0/24", "10.0.2.0/24"]
    }
    vnet-danizen-2 = {
      location        = "westus2"
      address_space   = ["10.1.0.0/16"]
      subnet_prefixes = ["10.1.1.0/24", "10.1.2.0/24"]
    }
  }
}

resource "azurerm_network_security_group" "sg1" {
  name                = "nsg-danizen-1"
  location            = module.vnet["vnet-danizen-1"].vnet_location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_group" "sg2" {
  name                = "nsg-danizen-2"
  location            = module.vnet["vnet-danizen-2"].vnet_location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "sg1ssh" {
  name                        = "Allow SSH to subnet-app"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "10.0.1.0/24"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.sg1.name
}

resource "azurerm_subnet_network_security_group_association" "vnet1sg1" {
  subnet_id                 = module.vnet["vnet-danizen-1"].vnet_subnets[0]
  network_security_group_id = azurerm_network_security_group.sg1.id
}

resource "azurerm_network_security_rule" "sg2ssh" {
  name                        = "Allow SSH to subnet-app"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "10.1.1.0/24"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.sg2.name
}

resource "azurerm_subnet_network_security_group_association" "vnet2sg2" {
  subnet_id                 = module.vnet["vnet-danizen-2"].vnet_subnets[0]
  network_security_group_id = azurerm_network_security_group.sg2.id
}
