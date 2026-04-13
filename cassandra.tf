##----------------------------------------------------------------------------- 
## Cosmos DB Cassandra Cluster resource for managing Cassandra clusters
##-----------------------------------------------------------------------------
resource "azurerm_cosmosdb_cassandra_cluster" "example" {
  count                          = var.enabled && var.cassandra_enable && var.enable_cassandra_core ? 1 : 0
  name                           = format("%saccs", module.labels.id)
  resource_group_name            = var.resource_group_name
  location                       = var.location
  tags                           = module.labels.tags
  delegated_management_subnet_id = var.delegated_management_subnet_id
  default_admin_password         = var.default_admin_password
  authentication_method          = var.local_authentication_method
  hours_between_backups          = var.hours_between_backups

  identity {
    type = var.identity
  }

  repair_enabled = var.repair_enabled
  version        = var.cassandra_version

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
## Cosmos DB Cassandra Data Center resource for managing Cassandra DC
##-----------------------------------------------------------------------------
resource "azurerm_cosmosdb_cassandra_datacenter" "example" {
  depends_on                     = [azurerm_cosmosdb_cassandra_cluster.example]
  count                          = var.enabled && var.cassandra_enable && var.enable_cassandra_core ? 1 : 0
  name                           = format("%saccd", module.labels.id)
  location                       = var.location
  cassandra_cluster_id           = azurerm_cosmosdb_cassandra_cluster.example[0].id
  delegated_management_subnet_id = var.delegated_management_subnet_id
  node_count                     = var.node_count
  disk_count                     = var.disk_count
  sku_name                       = var.sku_name
  availability_zones_enabled     = var.availability_zones_enabled
  disk_sku                       = var.disk_sku
}

##----------------------------------------------------------------------------- 
## Cosmos DB Cassandra Keyspace resource for managing keyspaces in Cassandra
##-----------------------------------------------------------------------------
resource "azurerm_cosmosdb_cassandra_keyspace" "example" {
  count               = var.enabled && var.cassandra_enable ? 1 : 0
  name                = format("%sacck", module.labels.id)
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.db[0].name
  throughput          = var.max_throughput == null ? var.throughput : null


  dynamic "autoscale_settings" {
    for_each = var.max_throughput != null && var.throughput == null ? [1] : []
    content {
      max_throughput = var.max_throughput
    }
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
## Cosmos DB Cassandra Table resource for managing tables in a keyspace
##-----------------------------------------------------------------------------
resource "azurerm_cosmosdb_cassandra_table" "example" {
  count                 = var.enabled && var.cassandra_enable ? 1 : 0
  name                  = format("%sacct", module.labels.id)
  cassandra_keyspace_id = azurerm_cosmosdb_cassandra_keyspace.example[0].id
  throughput            = var.max_throughput == null ? var.throughput : null
  default_ttl           = var.default_ttl

  dynamic "autoscale_settings" {
    for_each = var.max_throughput != null && var.throughput == null ? [1] : []
    content {
      max_throughput = var.max_throughput
    }
  }
  dynamic "schema" {
    for_each = length(var.cassandra_schema_settings.column) > 0 ? [1] : []
    content {
      dynamic "column" {
        for_each = var.cassandra_schema_settings.column
        content {
          name = column.value.column_key_name
          type = column.value.column_key_type
        }
      }

      dynamic "partition_key" {
        for_each = var.cassandra_schema_settings.partition_key
        content {
          name = partition_key.value.partition_key_name
        }
      }

      dynamic "cluster_key" {
        for_each = var.cassandra_schema_settings.cluster_key != null ? var.cassandra_schema_settings.cluster_key : []
        content {
          name     = cluster_key.value.cluster_key_name
          order_by = cluster_key.value.cluster_key_order_by
        }
      }
    }
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
## Network Contributor role on delegated subnet for Cassandra managed instance
##-----------------------------------------------------------------------------
resource "azurerm_role_assignment" "cassandra_subnet_network_contributor" {
  count                = var.enabled && var.cassandra_enable && var.enable_cassandra_core ? 1 : 0
  scope                = var.delegated_management_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = var.role_principal_id
}
