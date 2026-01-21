##----------------------------------------------------------------------------- 
## Cosmos DB PostgreSQL Cluster resource for managing PostgreSQL clusters within Cosmos DB
##-----------------------------------------------------------------------------
resource "azurerm_cosmosdb_postgresql_cluster" "example" {
  count                           = var.enabled && var.postgresql_enable ? 1 : 0
  name                            = format("%sacpc", module.labels.id)
  resource_group_name             = var.resource_group_name
  location                        = var.location
  administrator_login_password    = var.administrator_login_password
  coordinator_storage_quota_in_mb = var.coordinator_storage_quota_in_mb
  coordinator_vcore_count         = var.coordinator_vcore_count
  node_count                      = var.node_count
  node_public_ip_access_enabled   = var.node_public_ip_access_enabled
  node_server_edition             = var.node_server_edition
  node_vcores                     = var.node_vcores
  citus_version                   = var.citus_version
  ha_enabled                      = var.ha_enabled
  node_storage_quota_in_mb        = var.node_storage_quota_in_mb
  sql_version                     = var.sql_version
  tags                            = module.labels.tags

  maintenance_window {
    day_of_week  = var.maintenance_window.day_of_week
    start_hour   = var.maintenance_window.start_hour
    start_minute = var.maintenance_window.start_minute
  }

  dynamic "timeouts" {
    for_each = var.timeouts
    iterator = item
    content {
      create = item.value.create
      read   = item.value.read
      update = item.value.update
      delete = item.value.delete
    }
  }
}

##----------------------------------------------------------------------------- 
## Cosmos DB PostgreSQL Cluster resource for managing PostgreSQL clusters within Cosmos DB
##-----------------------------------------------------------------------------
resource "azurerm_cosmosdb_postgresql_cluster" "replica_cluster" {
  count                           = var.enabled && var.postgres_replica_enable && var.postgresql_enable ? 1 : 0
  name                            = format("%sacpc-replica", module.labels.id)
  resource_group_name             = var.resource_group_name
  location                        = var.location
  administrator_login_password    = var.administrator_login_password
  coordinator_storage_quota_in_mb = var.coordinator_storage_quota_in_mb
  coordinator_vcore_count         = var.coordinator_vcore_count
  node_count                      = var.node_count
  node_public_ip_access_enabled   = var.node_public_ip_access_enabled
  node_server_edition             = var.node_server_edition
  node_vcores                     = var.node_vcores
  citus_version                   = var.citus_version
  ha_enabled                      = var.ha_enabled
  node_storage_quota_in_mb        = var.node_storage_quota_in_mb
  point_in_time_in_utc            = var.source_resource_id != null ? var.point_in_time_in_utc : null
  source_location                 = var.source_resource_id != null ? var.location : null
  source_resource_id              = var.source_resource_id != null ? var.source_resource_id : null
  sql_version                     = var.sql_version
  tags                            = module.labels.tags

  maintenance_window {
    day_of_week  = var.maintenance_window.day_of_week
    start_hour   = var.maintenance_window.start_hour
    start_minute = var.maintenance_window.start_minute
  }


  dynamic "timeouts" {
    for_each = var.timeouts
    iterator = item
    content {
      create = item.value.create
      read   = item.value.read
      update = item.value.update
      delete = item.value.delete
    }
  }
}

##----------------------------------------------------------------------------- 
## Cosmos DB PostgreSQL Firewall Rule resource for managing firewall rules for PostgreSQL clusters
##-----------------------------------------------------------------------------
resource "azurerm_cosmosdb_postgresql_firewall_rule" "example" {
  # 1. Transform the list into a map. Use Start IP as the key to ensure uniqueness.
  #    Logic: If enabled, loop. If not, return empty map {}.
  for_each = var.enabled && var.postgresql_enable ? { for r in var.ip_ranges : r.start_ip_address => r } : {}

  # 2. Generate a unique name for each rule. 
  #    We replace dots in the IP (10.0.0.1) with dashes (10-0-0-1) to make it Azure-compliant.
  name = format("%s-acpfr-%s", module.labels.id, replace(each.key, ".", "-"))

  cluster_id = azurerm_cosmosdb_postgresql_cluster.example[0].id

  # 3. Access values dynamically using 'each.value'
  start_ip_address = each.value.start_ip_address
  end_ip_address   = each.value.end_ip_address

  dynamic "timeouts" {
    for_each = var.timeouts
    iterator = item
    content {
      create = item.value.create
      read   = item.value.read
      update = item.value.update
      delete = item.value.delete
    }
  }
}

##----------------------------------------------------------------------------- 
## Cosmos DB PostgreSQL Node Configuration resource for managing configuration of PostgreSQL nodes
##-----------------------------------------------------------------------------
resource "azurerm_cosmosdb_postgresql_node_configuration" "example" {
  for_each = var.enabled && var.postgresql_enable ? var.postgresql_node_configurations : {}

  name       = each.key   # The configuration name (e.g., "array_nulls")
  value      = each.value # The configuration value (e.g., "on")
  cluster_id = azurerm_cosmosdb_postgresql_cluster.example[0].id

  dynamic "timeouts" {
    for_each = var.timeouts
    iterator = item
    content {
      create = item.value.create
      read   = item.value.read
      update = item.value.update
      delete = item.value.delete
    }
  }
}

##----------------------------------------------------------------------------- 
## Cosmos DB PostgreSQL Role resource for managing PostgreSQL roles
##-----------------------------------------------------------------------------
resource "azurerm_cosmosdb_postgresql_role" "example" {
  count      = var.enabled && var.postgresql_enable ? 1 : 0
  name       = substr(lower(replace(module.labels.id, "/[^0-9a-z]/", "")), 0, 63)
  cluster_id = azurerm_cosmosdb_postgresql_cluster.example[0].id
  password   = var.password
}

##----------------------------------------------------------------------------- 
## Private Endpoint for Cosmos DB for PostgreSQL
##-----------------------------------------------------------------------------
resource "azurerm_private_endpoint" "pep_postgres" {
  # Only create this if Postgres is enabled and Private Endpoints are enabled
  count = var.enabled && var.postgresql_enable && var.enable_private_endpoint_pgsql ? 1 : 0

  name                = var.resource_position_prefix ? format("pe-cosmos-pg-%s", local.name) : format("%s-pe-cosmos-pg", local.name)
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = module.labels.tags

  private_dns_zone_group {
    name = var.resource_position_prefix ? format("dns-zone-group-cosmos-pg-%s", local.name) : format("%s-dns-zone-group-cosmos-pg", local.name)
    # IMPORTANT: You must pass the ID for 'privatelink.postgres.cosmos.azure.com' here
    private_dns_zone_ids = [var.private_dns_zone_ids]
  }

  private_service_connection {
    name                 = format("cosmos-pg-%s-connection", module.labels.id)
    is_manual_connection = false

    # Connect to the Postgres Cluster, NOT the Cosmos Account
    private_connection_resource_id = azurerm_cosmosdb_postgresql_cluster.example[0].id

    # The required subresource for Cosmos Postgres is ALWAYS "coordinator"
    subresource_names = ["coordinator"]
  }
}