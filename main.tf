// Tags
locals {
  tags = {
    class      = var.tag_class
    instructor = var.tag_instructor
    semester   = var.tag_semester
  }
}

// Existing Resources

/// Subscription ID

# data "azurerm_subscription" "current" {
# }

// Random Suffix Generator

resource "random_integer" "deployment_id_suffix" {
  min = 100
  max = 999
}

// Resource Group

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.class_name}-${var.student_name}-${var.environment}-${var.location}-${random_integer.deployment_id_suffix.result}"
  location = var.location

  tags = local.tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.class_name}-${var.student_name}-${var.environment}-${var.location}-${random_integer.deployment_id_suffix.result}"
  address_space       = ["10.7.29.0/29"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-${var.class_name}-${var.student_name}-${var.environment}-${var.location}-${random_integer.deployment_id_suffix.result}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.7.29.0/29"]
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_mssql_server" "sqlserver" {
  name                         = "uniqueazuresqlserver-${var.class_name}-${var.student_name}-${var.environment}-${var.location}-${random_integer.deployment_id_suffix.result}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = "4dm1n157r470r"
  administrator_login_password = "4-v3ry-53cr37-p455w0rd"
}

#add sql db here

resource "azurerm_mssql_virtual_network_rule" "vnet_rule" {
  name      = "sql-vnet-rule-${var.class_name}-${var.student_name}-${var.environment}-${var.location}-${random_integer.deployment_id_suffix.result}"
  server_id = azurerm_mssql_server.sqlserver.id
  subnet_id = azurerm_subnet.subnet.id
}


// Storage Account

resource "azurerm_storage_account" "storage" {
  name                     = "sto${var.class_name}${var.student_name}${var.environment}${random_integer.deployment_id_suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = local.tags
}

