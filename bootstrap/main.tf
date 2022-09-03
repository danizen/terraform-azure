# Configure the Azure provider
terraform {
  required_version = ">= 1.1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }
  backend "local" {}
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

# Create a storage account for application artifacts
resource "azurerm_storage_account" "artifacts" {
  name                     = "sadanizenartifacts"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

# Create a container for that account
resource "azurerm_storage_container" "apps" {
  name                  = "apps"
  storage_account_name  = azurerm_storage_account.artifacts.name
  container_access_type = "private"
}

# Create a container for that account
resource "azurerm_storage_container" "functions" {
  name                  = "functions"
  storage_account_name  = azurerm_storage_account.artifacts.name
  container_access_type = "private"
}

# Create a storage account for terraform
resource "azurerm_storage_account" "tf" {
  name                     = "sadanizentf"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

# Create a container for terraform
# Create a container for that account
resource "azurerm_storage_container" "state" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tf.name
  container_access_type = "private"
}
