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
  location    = "eastus"
}

##-----------------------------------------------------------------------------
## Virtual Network
##-----------------------------------------------------------------------------
module "vnet" {
  source              = "terraform-az-modules/vnet/azurerm"
  version             = "1.0.3"
  name                = "test"
  environment         = "stage"
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
  environment          = "stage"
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
      resource_type = "cosmos_db_gremlin"
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
  name                = "test"
  environment         = "prod"
  label_order         = ["name", "environment", "location"]
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
}

##-----------------------------------------------------------------------------
## Cosmos DB module call
##-----------------------------------------------------------------------------
module "CosmosDB" {
  source                            = "./../../"
  name                              = "test"
  environment                       = "prod"
  resource_group_name               = module.resource_group.resource_group_name
  location                          = module.resource_group.resource_group_location
  virtual_network_id                = module.vnet.vnet_id
  role_principal_id                 = data.azurerm_client_config.current.object_id
  user_object_id                    = data.azurerm_client_config.current.object_id
  gremlin_enable                    = true
  backup_type                       = "Periodic"
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
    },
    {
      name = "EnableGremlin"
    }
  ]

  geo_location = [
    {
      location          = "eastus"
      failover_priority = 0
    },
    # {
    #   location          = "westus"
    #   failover_priority = 1
    # }
  ]
  enable_private_endpoint     = true
  private_dns_zone_ids        = module.private-dns-zone.private_dns_zone_ids["cosmos_db_gremlin"]
  private_endpoint_subnet_id  = module.subnet.subnet_ids.subnet1
  diagnostic_settings_enabled = true
  log_analytics_workspace_id  = module.log-analytics.workspace_id

}
