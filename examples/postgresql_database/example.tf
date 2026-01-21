provider "azurerm" {
  features {}
}


data "azurerm_client_config" "current" {}

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
  location    = "canadacentral"
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

##-----------------------------------------------------------------------------
## Private DNS Zone
##-----------------------------------------------------------------------------
module "private-dns-zone" {
  source              = "terraform-az-modules/private-dns/azurerm"
  version             = "1.0.4"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  label_order         = ["name", "environment", "location"]
  name                = "test"
  environment         = "prod"
  private_dns_config = [
    {
      resource_type = "cosmos_db_postgresql"
      vnet_ids      = [module.vnet.vnet_id]
    },
  ]
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
  source                            = "./../../"
  resource_group_name               = module.resource_group.resource_group_name
  name                              = "ok"
  environment                       = "qa"
  location                          = "canadacentral"
  virtual_network_id                = module.vnet.vnet_id
  role_principal_id                 = data.azurerm_client_config.current.object_id
  user_object_id                    = data.azurerm_client_config.current.object_id
  postgresql_enable                 = true
  is_virtual_network_filter_enabled = true
  virtual_network_rule = [
    {
      id                                   = module.subnet.subnet_ids.subnet1
      ignore_missing_vnet_service_endpoint = false
    }
  ]

  capabilities = [
    {
      name = "EnableAggregationPipeline"
    }
  ]

  geo_location = [
    {
      location          = "canadacentral"
      failover_priority = 0
    },
    # {
    #   location          = "canadaeast"
    #   failover_priority = 1
    # }
  ]
  postgresql_node_configurations = {
    array_nulls = "on"
  }
  diagnostic_settings_enabled   = true
  log_analytics_workspace_id    = module.log-analytics.workspace_id
  enable_private_endpoint_pgsql = true
  private_endpoint_subnet_id    = module.subnet.subnet_ids.subnet1
  private_dns_zone_ids          = module.private-dns-zone.private_dns_zone_ids["cosmos_db_postgresql"]

  # ip_ranges = [
  #   {
  #     start_ip_address = "10.0.1.0"
  #     end_ip_address   = "10.0.1.255"
  #   },
  #   {
  #     start_ip_address = "52.1.0.0"
  #     end_ip_address   = "52.1.0.50"
  #   }
  # ]
}

