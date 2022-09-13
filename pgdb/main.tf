# Configure the Azure provider
terraform {
  required_version = ">= 1.1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
    random = {
      source = "hashicorp/random"
      version = "~> 3.4.3"
    }
  }
  backend "azurerm" {
  }
}

provider "azurerm" {
  features {}
}

provider "random" {
  # Configuration options
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

# Keep it DRY
locals {
  myip = "${chomp(data.http.myip.response_body)}"
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.region_name

  tags = {
    Environment = var.environment
    Team        = var.team
  }
}

resource "random_string" "dbpass" {
  length           = 16
  special          = true
  min_lower        = 1
  min_numeric      = 1
  min_upper        = 1
  min_special      = 1
  override_special = "#%*-_=+"
}

resource "azurerm_postgresql_flexible_server" "db" {
  name                   = var.server_name
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  version                = "13"
  administrator_login    = var.administrator_login
  administrator_password = random_string.dbpass.result

  # this is where it gets tricky
  # delegated_subnet_id    = azurerm_subnet.default.id
  # private_dns_zone_id    = azurerm_private_dns_zone.default.id

  storage_mb = 32768

  sku_name = var.sku_name

  zone                   = "1"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "dbfw" {
  name                = "home-fw"
  server_id           = azurerm_postgresql_flexible_server.db.id
  start_ip_address    = local.myip
  end_ip_address      = local.myip
}

resource "azurerm_postgresql_flexible_server_database" "db" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.db.id
  collation = "en_US.utf8"
  charset   = "utf8"
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "postgresql_server_name" {
  value = azurerm_postgresql_flexible_server.db.name
}

output "postgresql_database_name" {
  value = azurerm_postgresql_flexible_server_database.db.name
}

output "allowed_ips" {
  value = [local.myip]
}

output "administrator_login" {
  value = azurerm_postgresql_flexible_server.db.administrator_login
}

output "administrator_password" {
  value = azurerm_postgresql_flexible_server.db.administrator_password
  sensitive = true
}
