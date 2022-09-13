variable "resource_group_name" {
  default = "rg-danizen-flexpg"
}

variable "region_name" {
  default = "East US 2"
}

variable "environment" {
  default = "Terraform Database"
}

variable "team" {
  default = "DevOps"
}

variable "sku_name" {
  default = "B_Standard_B1ms"
}

variable "server_name" {
  default = "danizen-flexpg"
}

variable "administrator_login" {
  default = "postgres"
}

variable "database_name" {
  default = "appdb"
}
