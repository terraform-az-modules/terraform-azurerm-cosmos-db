provider "azurerm" {
  features {}
}

provider "random" {}

data "azurerm_client_config" "current" {}
data "azuread_service_principal" "example" {
  display_name = "Azure Cosmos DB"
}

locals {
  name        = "app"
  environment = "test"
  label_order = ["name", "environment"]
}

##-----------------------------------------------------------------------------
## Resource Group
##-----------------------------------------------------------------------------
module "resource_group" {
  source      = "terraform-az-modules/resource-group/azurerm"
  version     = "1.0.3"
  name        = "test"
  environment = "stage"
  label_order = ["environment", "name", "location"]
  location    = "eastus"
}

##-----------------------------------------------------------------------------
## Virtual Network
##-----------------------------------------------------------------------------
module "vnet" {
  source              = "terraform-az-modules/vnet/azurerm"
  version             = "1.0.3"
  name                = "app"
  environment         = "qa"
  label_order         = ["name", "environment", "location"]
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_spaces      = ["10.0.0.0/16"]
}

##-----------------------------------------------------------------------------
## Subnets
##-----------------------------------------------------------------------------
module "subnet" {
  source               = "terraform-az-modules/subnet/azurerm"
  version              = "1.0.1"
  environment          = "qa"
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = module.vnet.vnet_name
  subnets = [
    {
      name              = "subnet1"
      subnet_prefixes   = ["10.0.1.0/24"]
      service_endpoints = ["Microsoft.AzureCosmosDB"]
    }
  ]
  enable_route_table = true
  route_tables = [
    {
      name = "pub"
      routes = [
        {
          name           = "rt-test"
          address_prefix = "0.0.0.0/0"
          next_hop_type  = "Internet"
        }
      ]
    }
  ]
}

##------------------------------------------------------------------------------
## Key Vault
## ------------------------------------------------------------------------------
module "vault" {
  source                        = "terraform-az-modules/key-vault/azurerm"
  version                       = "1.0.1"
  name                          = "ap12"
  environment                   = "qa"
  label_order                   = ["name", "environment", "location"]
  resource_group_name           = module.resource_group.resource_group_name
  location                      = module.resource_group.resource_group_location
  subnet_id                     = module.subnet.subnet_ids.subnet1
  public_network_access_enabled = true
  sku_name                      = "standard"
  enable_private_endpoint       = false
  # private_dns_zone_ids          = module.private_dns_zone.private_dns_zone_ids.key_vault
  network_acls = {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = ["0.0.0.0/0"]
  }
  reader_objects_ids = {
    "Key Vault Administrator" = {
      role_definition_name = "Key Vault Administrator"
      principal_id         = data.azurerm_client_config.current.object_id
    }
  }
  diagnostic_setting_enable = false
  # log_analytics_workspace_id = module.log-analytics.workspace_id
}

##-----------------------------------------------------------------------------
## Log Analytics
##-----------------------------------------------------------------------------
module "log-analytics" {
  source              = "terraform-az-modules/log-analytics/azurerm"
  version             = "1.0.2"
  name                = "core"
  environment         = "dev"
  label_order         = ["name", "environment", "location"]
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
}

##-----------------------------------------------------------------------------
## Cosmos DB module call
## Deploy the Cosmos DB instance in the specified resource group and vnet.
##-----------------------------------------------------------------------------
module "CosmosDB" {
  depends_on                        = [module.vault]
  source                            = "./../../"
  resource_group_name               = module.resource_group.resource_group_name
  name                              = "core"
  environment                       = "qa"
  location                          = module.resource_group.resource_group_location
  virtual_network_id                = module.vnet.vnet_id
  role_principal_id                 = data.azuread_service_principal.example.object_id
  private_endpoint_subnet_id        = module.subnet.subnet_ids.subnet1
  user_object_id                    = data.azurerm_client_config.current.object_id
  enable_sql_database               = true
  kind                              = "GlobalDocumentDB"
  is_virtual_network_filter_enabled = true
  virtual_network_rule = [

    {
      id                                   = module.subnet.subnet_ids.subnet1
      ignore_missing_vnet_service_endpoint = false
    }
  ]

  geo_location = [
    {
      location          = "eastus"
      failover_priority = 0
    },
    {
      location          = "westus"
      failover_priority = 1
    }
  ]
  diagnostic_settings_enabled = true
  log_analytics_workspace_id  = module.log-analytics.workspace_id

  cmk_encryption_enabled = false
  # key_vault_id           = module.vault.id
}
