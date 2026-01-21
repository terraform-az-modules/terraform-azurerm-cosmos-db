##----------------------------------------------------------------------------- 
## Cosmos DB SQL Container resource for managing SQL containers within Cosmos DB
##-----------------------------------------------------------------------------
resource "azurerm_cosmosdb_sql_container" "example" {
  count = var.enabled && var.enable_sql_database ? 1 : 0
  # name                  = format("%sacsc", module.labels.id)
  name                  = var.resource_position_prefix ? format("acsc-%s", local.name) : format("%s-acsc", local.name)
  resource_group_name   = var.resource_group_name
  account_name          = azurerm_cosmosdb_account.db[0].name
  database_name         = azurerm_cosmosdb_sql_database.example[0].name
  partition_key_paths   = var.sql_partition_key_paths
  partition_key_version = var.sql_partition_key_version
  throughput            = var.max_throughput == null ? var.throughput : null
  dynamic "autoscale_settings" {
    for_each = var.max_throughput != null && var.throughput == null ? [1] : []
    content {
      max_throughput = var.max_throughput
    }
  }
  dynamic "indexing_policy" {
    for_each = length(var.sql_indexing_policy_settings) > 0 ? [1] : []
    content {
      indexing_mode = var.sql_indexing_policy_settings.sql_indexing_mode != null ? var.sql_indexing_policy_settings.sql_indexing_mode : null

      dynamic "included_path" {
        for_each = var.sql_indexing_policy_settings.sql_included_path != null ? [1] : []
        content {
          path = var.sql_indexing_policy_settings.sql_included_path
        }
      }

      dynamic "excluded_path" {
        for_each = var.sql_indexing_policy_settings.sql_excluded_path != null ? [1] : []
        content {
          path = var.sql_indexing_policy_settings.sql_excluded_path
        }
      }
    }
  }

  unique_key {
    paths = var.unique_key.paths
  }
}

##----------------------------------------------------------------------------- 
## Cosmos DB SQL Database resource for managing SQL databases within Cosmos DB
##-----------------------------------------------------------------------------
resource "azurerm_cosmosdb_sql_database" "example" {
  count = var.enabled && var.enable_sql_database ? 1 : 0
  # name                = format("%sacsd", module.labels.id)
  name                = var.resource_position_prefix ? format("acsd-%s", local.name) : format("%s-acsd", local.name)
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
## Cosmos DB SQL Dedicated Gateway resource for managing dedicated gateway instances for SQL APIs
##-----------------------------------------------------------------------------
resource "azurerm_cosmosdb_sql_dedicated_gateway" "example" {
  count               = var.enabled && var.enable_sql_database ? 1 : 0
  cosmosdb_account_id = azurerm_cosmosdb_account.db[0].id
  instance_count      = var.instance_count
  instance_size       = var.instance_size
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
## Cosmos DB SQL Function resource for managing stored SQL functions in Cosmos DB
##-----------------------------------------------------------------------------
resource "azurerm_cosmosdb_sql_function" "example" {
  count = var.enabled && var.enable_sql_database ? 1 : 0
  # name         = format("%sacsf", module.labels.id)
  name         = var.resource_position_prefix ? format("acsf-%s", local.name) : format("%s-acsf", local.name)
  container_id = azurerm_cosmosdb_sql_container.example[0].id
  body         = var.function_body
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
## Cosmos DB SQL Role Definition resource for managing SQL role definitions
##-----------------------------------------------------------------------------
resource "azurerm_cosmosdb_sql_role_definition" "example" {
  count = var.enabled && var.enable_sql_database ? 1 : 0
  # name                = format("%sacsrd", module.labels.id)
  name                = var.resource_position_prefix ? format("acsrd-%s", local.name) : format("%s-acsrd", local.name)
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.db[0].name
  type                = var.role_type
  assignable_scopes   = [azurerm_cosmosdb_account.db[0].id]
  permissions {
    data_actions = var.permissions_data_actions
  }
}

##-----------------------------------------------------------------------------
## Generate a random UUID for SQL Role Assignment names
##-----------------------------------------------------------------------------
resource "random_uuid" "sql_role_assignment" {}

##----------------------------------------------------------------------------- 
## Cosmos DB SQL Role Assignment resource for assigning roles to principals
##-----------------------------------------------------------------------------
resource "azurerm_cosmosdb_sql_role_assignment" "example" {
  count = var.enabled && var.enable_sql_database ? 1 : 0
  name  = random_uuid.sql_role_assignment.result
  # name                = "d4f3e4e6-7a1f-4698-9b52-8f51a76bc849" # Concatenate the label ID and a UUID
  # name                = var.resource_position_prefix ? format("acsra-%s", local.name) : format("%s-acsra", local.name)
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.db[0].name
  role_definition_id  = azurerm_cosmosdb_sql_role_definition.example[0].id
  principal_id        = var.user_object_id
  scope               = azurerm_cosmosdb_account.db[0].id
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
## Cosmos DB SQL Stored Procedure resource for managing SQL stored procedures
##-----------------------------------------------------------------------------
resource "azurerm_cosmosdb_sql_stored_procedure" "example" {
  count               = var.enabled && var.enable_sql_database ? 1 : 0
  name                = format("%sacssp", module.labels.id)
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.db[0].name
  database_name       = azurerm_cosmosdb_sql_database.example[0].name
  container_name      = azurerm_cosmosdb_sql_container.example[0].name
  body                = var.function_body

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
## Cosmos DB SQL Trigger resource for managing SQL triggers in Cosmos DB
##-----------------------------------------------------------------------------
resource "azurerm_cosmosdb_sql_trigger" "example" {
  count        = var.enabled && var.enable_sql_database ? 1 : 0
  name         = format("%sacst", module.labels.id)
  container_id = azurerm_cosmosdb_sql_container.example[0].id
  body         = var.function_body
  operation    = var.operation_type
  type         = var.request_type
}