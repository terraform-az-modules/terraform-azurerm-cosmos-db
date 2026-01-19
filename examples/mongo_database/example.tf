provider "azurerm" {
  features {}
}


data "azurerm_client_config" "current" {}

locals {
  name        = "test"
  environment = "qa"
  label_order = ["name", "environment"]
}

##-----------------------------------------------------------------------------
## Resource Group
##-----------------------------------------------------------------------------
module "resource_group" {
  source      = "terraform-az-modules/resource-group/azurerm"
  version     = "1.0.3"
  name        = "test"
  environment = "qa"
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
    },
    {
      name            = "subnet2"
      subnet_prefixes = ["10.0.2.0/24"]
    },
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
      resource_type = "cosmos_db_mongo"
      vnet_ids      = [module.vnet.vnet_id]
    },
  ]
}

##-----------------------------------------------------------------------------
## Cosmos DB module call
## Deploy the Cosmos DB instance in the specified resource group and vnet.
##-----------------------------------------------------------------------------
module "CosmosDB" {
  source                            = "./../../"
  resource_group_name               = module.resource_group.resource_group_name
  location                          = "canadacentral"
  name                              = "test"
  environment                       = "prod"
  virtual_network_id                = module.vnet.vnet_id
  role_principal_id                 = data.azurerm_client_config.current.object_id
  private_endpoint_subnet_id        = module.subnet.subnet_ids.subnet1
  enable_private_endpoint           = true
  private_dns_zone_ids              = module.private-dns-zone.private_dns_zone_ids["cosmos_db_mongo"]
  user_object_id                    = data.azurerm_client_config.current.object_id
  mongodb_enable                    = true
  kind                              = "MongoDB"
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
      name = "EnableMongo"
    },
    {
      name = "EnableMongoRoleBasedAccessControl"
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
}
