# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }
  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name        = var.resource_group_name
  location    = var.region_name

  tags = {
    Environment = "Terraform Bootstrap"
    Team = "DevOps"
  }
}

# Create a storage account for application artifacts
resource "azurerm_storage_account" "artifacts" {
  name                      = "sadanizenartifacts"
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location
  account_tier              = "Standard"
  account_replication_type  = "GRS"
}

# Create a container for that account
resource "azurerm_storage_container" "apps" {
  name                      = "danizencfgapps"
  storage_account_name      = azurerm_storage_account.artifacts.name
  container_access_type     = "private"
}

# Create a container for that account
resource "azurerm_storage_container" "functions" {
  name                      = "danizencfgfunctions"
  storage_account_name      = azurerm_storage_account.artifacts.name
  container_access_type     = "private"
}

# Create a storage account for terraform
resource "azurerm_storage_account" "tf" {
  name                      = "sadanizentf"
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location
  account_tier              = "Standard"
  account_replication_type  = "GRS"
}

# Create a container for terraform
# Create a container for that account
resource "azurerm_storage_container" "state" {
  name                      = "danizentfstate"
  storage_account_name      = azurerm_storage_account.tf.name
  container_access_type     = "private"
}
