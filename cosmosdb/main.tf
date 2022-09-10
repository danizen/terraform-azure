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

resource "azurerm_cosmosdb_account" "mongo" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = azurerm_resource_group.rg.location

  offer_type = "Standard"
  kind = "MongoDB"

  consistency_policy {
    consistency_level = "BoundedStaleness"
    max_interval_in_seconds = 60
    max_staleness_prefix = 100
  }

  enable_free_tier = true

  mongo_server_version = "4.0"

  enable_automatic_failover = false

  geo_location {
    location = azurerm_resource_group.rg.location
    failover_priority = 0
  }

  backup {
    type = "Periodic"
    interval_in_minutes = 1440
    retention_in_hours = 720
    storage_redundancy = "Local"
  }

  capabilities {
    name = "EnableAggregationPipeline"
  }

  capabilities {
    name = "EnableMongo"
  }

  capabilities {
    name = "MongoDBv3.4"
  }

  capabilities {
    name = "mongoEnableDocLevelTTL"
  }
}

resource "azurerm_cosmosdb_mongo_database" "powrest" {
  name                = "powrest"
  resource_group_name = azurerm_cosmosdb_account.mongo.resource_group_name
  account_name        = azurerm_cosmosdb_account.mongo.name
}

resource "azurerm_cosmosdb_mongo_collection" "customers" {
  name                = "customers"
  resource_group_name = azurerm_cosmosdb_account.mongo.resource_group_name
  account_name        = azurerm_cosmosdb_account.mongo.name
  database_name       = azurerm_cosmosdb_mongo_database.powrest.name

  default_ttl_seconds = "777"
  shard_key           = "uniqueKey"
  throughput          = 400

  index {
    keys   = ["_id"]
    unique = true
  }
}
