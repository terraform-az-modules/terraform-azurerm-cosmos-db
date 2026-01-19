##-----------------------------------------------------------------------------
## Local values
##-----------------------------------------------------------------------------
locals {
  mongo_primary_db_name = length(var.mongodb_databases) > 0 ? var.mongodb_databases[0].name : null
}

##-----------------------------------------------------------------------------
## Cosmos DB Mongo Database resource for managing MongoDB databases within Cosmos DB
##-----------------------------------------------------------------------------
resource "azurerm_cosmosdb_mongo_database" "mongo_db" {
  for_each            = var.kind == "MongoDB" ? { for db in var.mongodb_databases : db.name => db } : {}
  name                = each.value.name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.db[0].name
  throughput          = each.value.max_throughput == null ? each.value.throughput : null

  #Add autoscale settings
  dynamic "autoscale_settings" {
    for_each = each.value.throughput == null && each.value.max_throughput != null ? [1] : []
    content {
      max_throughput = each.value.max_throughput
    }
  }

  #Lifecycle management
  lifecycle {
    ignore_changes = [throughput]
  }
}

##----------------------------------------------------------------------------- 
## Cosmos DB MongoDB Collection resource for managing MongoDB collections
##-----------------------------------------------------------------------------
resource "azurerm_cosmosdb_mongo_collection" "main" {
  depends_on = [azurerm_cosmosdb_mongo_database.mongo_db]
  for_each = {
    for collection in flatten([
      for db in var.mongodb_databases : [
        for collection in db.collections : {
          db_name    = db.name
          collection = collection
        }
      ] if length(db.collections) > 0
    ]) : "${collection.db_name}.${collection.collection.name}" => collection
  }

  name                   = each.value.collection.name
  resource_group_name    = var.resource_group_name
  account_name           = azurerm_cosmosdb_account.db[0].name
  database_name          = azurerm_cosmosdb_mongo_database.mongo_db[each.value.db_name].name
  shard_key              = each.value.collection.shard_key
  throughput             = each.value.collection.max_throughput == null ? each.value.collection.throughput : null
  default_ttl_seconds    = each.value.collection.default_ttl_seconds
  analytical_storage_ttl = each.value.collection.analytical_storage_ttl

  dynamic "autoscale_settings" {
    for_each = each.value.collection.max_throughput != null && each.value.collection.throughput == null ? [1] : []
    content {
      max_throughput = each.value.collection.max_throughput
    }
  }

  dynamic "index" {
    for_each = each.value.collection.indexes
    content {
      keys   = index.value.keys
      unique = try(index.value.unique, false)
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
    ignore_changes = [throughput, index] # ADD THIS
  }
}

##----------------------------------------------------------------------------- 
## Cosmos DB Mongo Role Definition resource for managing MongoDB role definitions
##-----------------------------------------------------------------------------
resource "azurerm_cosmosdb_mongo_role_definition" "example" {
  count                    = var.enabled && var.mongodb_enable && var.role_name != null && local.mongo_primary_db_name != null ? 1 : 0
  cosmos_mongo_database_id = azurerm_cosmosdb_mongo_database.mongo_db[local.mongo_primary_db_name].id
  role_name                = var.role_name

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

  dynamic "privilege" {
    for_each = var.privileges
    content {
      actions = privilege.value.actions

      resource {
        collection_name = privilege.value.resource.collection_name
        db_name         = privilege.value.resource.db_name
      }
    }
  }
}

##----------------------------------------------------------------------------- 
## Cosmos DB Mongo User Definition resource for managing MongoDB user accounts
##-----------------------------------------------------------------------------
resource "azurerm_cosmosdb_mongo_user_definition" "example" {
  count                    = var.enabled && var.mongodb_enable && var.enable_mongo_user && local.mongo_primary_db_name != null ? 1 : 0
  cosmos_mongo_database_id = azurerm_cosmosdb_mongo_database.mongo_db[local.mongo_primary_db_name].id
  username                 = var.username
  password                 = var.password
}