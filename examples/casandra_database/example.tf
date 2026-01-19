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
  environment = "prod"
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
  environment         = "prod"
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
  environment          = "prod"
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = module.vnet.vnet_name
  subnets = [
    {
      name              = "subnet1"
      subnet_prefixes   = ["10.0.1.0/24"]
      service_endpoints = ["Microsoft.AzureCosmosDB"]
    },
    {
      name            = "subnet2"
      subnet_prefixes = ["10.0.2.0/24"]

      # Delegation
      delegations = [
        {
          name = "Microsoft.DocumentDB/cassandraClusters"
          service_delegations = [
            {
              name    = "Microsoft.DocumentDB/cassandraClusters"
              actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
              # Note: In some versions, 'actions' might not be required or is implicit
            }
          ]
        }
      ]
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
      resource_type = "cosmos_db_cassandra"
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
  source                         = "./../../"
  resource_group_name            = module.resource_group.resource_group_name
  location                       = module.resource_group.resource_group_location
  name                           = "test"
  environment                    = "prod"
  virtual_network_id             = module.vnet.vnet_id
  role_principal_id              = data.azurerm_client_config.current.object_id
  delegated_management_subnet_id = module.subnet.subnet_ids.subnet2
  user_object_id                 = data.azurerm_client_config.current.object_id
  cassandra_enable               = true
  backup_type                    = "Periodic"
  capabilities = [
    {
      name = "EnableAggregationPipeline"
    },
    {
      name = "EnableCassandra"
    }
  ]

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
    # {
    #   location          = "westus"
    #   failover_priority = 1
    # }
  ]
  enable_private_endpoint     = true
  private_dns_zone_ids        = module.private-dns-zone.private_dns_zone_ids["cosmos_db_cassandra"]
  private_endpoint_subnet_id  = module.subnet.subnet_ids.subnet1
  diagnostic_settings_enabled = true
  log_analytics_workspace_id  = module.log-analytics.workspace_id
}
