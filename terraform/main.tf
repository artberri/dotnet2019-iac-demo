variable "sql_username" {
    description = "Username for the SQL Server."
}

variable "sql_password" {
    description = "Password for the SQL Server."
}

provider "azurerm" {
  version = "~> 1.30"
}

provider "archive" {
  version = "~> 1.2"
}

locals {
  prefix = "terraformdn2019"
}

data "archive_file" "app" {
  type        = "zip"
  source_dir  = "../src/bin/Debug/netcoreapp2.1/publish"
  output_path = "${path.module}/files/app.zip"
}

resource "azurerm_resource_group" "main" {
  name     = "${local.prefix}-rg"
  location = "West Europe"
}

resource "azurerm_storage_account" "main" {
  name                     = lower("${local.prefix}sa")
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
}

resource "azurerm_storage_container" "main" {
  name                  = "${local.prefix}-c"
  resource_group_name   = azurerm_resource_group.main.name
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "main" {
  name                   = "${local.prefix}-b"
  resource_group_name    = azurerm_resource_group.main.name
  storage_account_name   = azurerm_storage_account.main.name
  storage_container_name = azurerm_storage_container.main.name
  type                   = "block"
  source                 = data.archive_file.app.output_path
}

data "azurerm_storage_account_sas" "main" {
  connection_string = "${azurerm_storage_account.main.primary_connection_string}"
  https_only        = true

  resource_types {
    service   = false
    container = false
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = "2018-03-21"
  expiry = "2100-01-01"

  permissions {
    read    = true
    write   = false
    delete  = false
    list    = false
    add     = false
    create  = false
    update  = false
    process = false
  }
}

resource "azurerm_application_insights" "main" {
  name                = "${local.prefix}-ai"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "Web"
}

resource "azurerm_sql_server" "main" {
  name                         = "${local.prefix}-sql"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = var.sql_username
  administrator_login_password = var.sql_password
}

resource "azurerm_sql_database" "main" {
  name                             = "${local.prefix}-db"
  resource_group_name              = azurerm_resource_group.main.name
  location                         = azurerm_resource_group.main.location
  server_name                      = azurerm_sql_server.main.name
  requested_service_objective_name = "S0"
}

resource "azurerm_app_service_plan" "main" {
  name                = "${local.prefix}-asp"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  kind                = "App"

  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "main" {
  name                = "${local.prefix}-as"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  app_service_plan_id = azurerm_app_service_plan.main.id

  app_settings = {
    "WEBSITE_RUN_FROM_ZIP"                   = "${azurerm_storage_blob.main.url}${data.azurerm_storage_account_sas.main.sas}"
    "ApplicationInsights:InstrumentationKey" = azurerm_application_insights.main.instrumentation_key
    "APPINSIGHTS_INSTRUMENTATIONKEY"         = azurerm_application_insights.main.instrumentation_key
    "ASPNETCORE_ENVIRONMENT"                 = "Development"
  }

  connection_string {
    name  = "DbConnection"
    type  = "SQLAzure"
    value = "Server=tcp:${azurerm_sql_server.main.fully_qualified_domain_name};initial catalog=${azurerm_sql_database.main.name};user ID=${var.sql_username};password=${var.sql_password};Min Pool Size=0;Max Pool Size=30;Persist Security Info=true;"
  }
}

locals {
  outbound_ip_addresses = split(",", azurerm_app_service.main.outbound_ip_addresses)
}

resource "azurerm_sql_firewall_rule" "test" {
  name                = "FR${element(local.outbound_ip_addresses, count.index)}"
  resource_group_name = azurerm_resource_group.main.name
  server_name         = azurerm_sql_server.main.name
  start_ip_address    = element(local.outbound_ip_addresses, count.index)
  end_ip_address      = element(local.outbound_ip_addresses, count.index)
  count               = length(local.outbound_ip_addresses)
}

output "endpoint" {
    value = "https://${azurerm_app_service.main.default_site_hostname}"
}
