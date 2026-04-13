##----------------------------------------------------------------------------- 
## Cosmos DB Gremlin Database resource for managing Gremlin databases
##-----------------------------------------------------------------------------
resource "azurerm_cosmosdb_gremlin_database" "example" {
  count               = var.enabled && var.gremlin_enable ? 1 : 0
  depends_on          = [azurerm_cosmosdb_account.db]
  name                = format("%sacgt", module.labels.id)
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

  lifecycle {
    ignore_changes = [throughput]
  }
}

##----------------------------------------------------------------------------- 
## Cosmos DB Gremlin Graph resource for managing Gremlin graphs within the database
##-----------------------------------------------------------------------------
resource "azurerm_cosmosdb_gremlin_graph" "example" {
  count                 = var.enabled && var.gremlin_enable ? 1 : 0
  name                  = format("%sacgg", module.labels.id)
  depends_on            = [azurerm_cosmosdb_gremlin_database.example]
  resource_group_name   = var.resource_group_name
  account_name          = azurerm_cosmosdb_account.db[0].name
  database_name         = azurerm_cosmosdb_gremlin_database.example[0].name
  partition_key_path    = var.partition_key_path
  throughput            = var.max_throughput == null ? var.throughput : null
  partition_key_version = var.partition_key_version

  dynamic "autoscale_settings" {
    for_each = var.max_throughput != null && var.throughput == null ? [1] : []
    content {
      max_throughput = var.max_throughput
    }
  }


  dynamic "index_policy" {
    for_each = var.index_policy_settings != null ? [1] : []
    content {
      automatic      = var.index_policy_settings.indexing_automatic
      indexing_mode  = var.index_policy_settings.indexing_mode
      included_paths = var.index_policy_settings.included_paths
      excluded_paths = var.index_policy_settings.excluded_paths
    }
  }

  dynamic "conflict_resolution_policy" {
    for_each = var.conflict_resolution_mode != null ? [1] : []
    content {
      mode                          = var.conflict_resolution_mode
      conflict_resolution_path      = var.conflict_resolution_mode == "LastWriterWins" ? var.conflict_resolution_path : null
      conflict_resolution_procedure = var.conflict_resolution_mode == "Custom" ? var.conflict_resolution_procedure : null
    }
  }

  dynamic "unique_key" {
    for_each = length(var.unique_key_path) > 0 ? [1] : []
    content {
      paths = var.unique_key_path
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