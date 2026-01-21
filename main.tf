##-----------------------------------------------------------------------------
## Tagging Module – Applies standard tags to all resources
##-----------------------------------------------------------------------------
module "labels" {
  source          = "terraform-az-modules/tags/azurerm"
  version         = "1.0.2"
  name            = var.custom_name == null ? var.name : var.custom_name
  location        = var.location
  environment     = var.environment
  managedby       = var.managedby
  label_order     = var.label_order
  repository      = var.repository
  deployment_mode = var.deployment_mode
  extra_tags      = var.extra_tags
}
##----------------------------------------------------------------------------- 
## Cosmos DB Account resource for managing the Azure Cosmos DB instance
##-----------------------------------------------------------------------------
resource "azurerm_cosmosdb_account" "db" {
  count                                 = var.enabled ? 1 : 0
  name                                  = var.resource_position_prefix ? format("cosmos-%s", local.name) : format("%s-cosmos", local.name)
  location                              = var.location
  resource_group_name                   = var.resource_group_name
  offer_type                            = var.offer_type
  kind                                  = var.kind
  automatic_failover_enabled            = var.automatic_failover_enabled
  minimal_tls_version                   = var.minimal_tls_version
  ip_range_filter                       = var.ip_range_filter
  free_tier_enabled                     = var.free_tier_enabled
  is_virtual_network_filter_enabled     = var.is_virtual_network_filter_enabled
  analytical_storage_enabled            = var.analytical_storage_enabled
  partition_merge_enabled               = var.partition_merge_enabled
  burst_capacity_enabled                = var.burst_capacity_enabled
  public_network_access_enabled         = var.public_network_access_enabled
  network_acl_bypass_for_azure_services = var.network_acl_bypass_for_azure_services

  # MongoDB-specific setting
  mongo_server_version = var.kind == "MongoDB" ? var.mongo_server_version : null

  # Virtual network rules for private access
  dynamic "virtual_network_rule" {
    for_each = var.virtual_network_rule
    content {
      id                                   = virtual_network_rule.value.id
      ignore_missing_vnet_service_endpoint = virtual_network_rule.value.ignore_missing_vnet_service_endpoint
    }
  }

  # CORS configuration
  dynamic "cors_rule" {
    for_each = var.enable_cors && length(var.allowed_origins) > 0 ? [1] : []
    content {
      allowed_headers    = var.allowed_headers
      allowed_methods    = var.allowed_methods
      allowed_origins    = var.allowed_origins
      exposed_headers    = var.exposed_headers
      max_age_in_seconds = var.max_interval_in_seconds
    }
  }

  # Backup configuration - FIXED typo and tier handling
  backup {
    type                = var.backup_type                                          # "Periodic" | "Continuous"
    tier                = var.backup_type == "Continuous" ? var.backup_tier : null # "Continuous30Days" or "Continuous7Days"
    interval_in_minutes = var.backup_type == "Periodic" ? var.interval_in_minutes : null
    retention_in_hours  = var.backup_type == "Periodic" ? var.retention_in_hours : null
    storage_redundancy  = var.backup_type == "Periodic" ? var.storage_redundancy : null
  }

  ## Dynamic block for API-specific capabilities
  dynamic "capabilities" {
    for_each = local.merged_capabilities
    content {
      name = capabilities.value.name
    }
  }

  ## Consistency policy settings
  consistency_policy {
    consistency_level       = var.consistency_level
    max_interval_in_seconds = var.max_interval_in_seconds
    max_staleness_prefix    = var.max_staleness_prefix
  }

  ## Geo-location configuration for multi-region
  dynamic "geo_location" {
    for_each = var.geo_location
    content {
      location          = geo_location.value.location
      failover_priority = geo_location.value.failover_priority
      zone_redundant    = lookup(geo_location.value, "zone_redundant", false)
    }
  }
  # Managed identity:
  # - CMK enabled  -> UserAssigned
  # - CMK disabled -> SystemAssigned
  identity {
    type = var.cmk_encryption_enabled ? "UserAssigned" : "SystemAssigned"

    identity_ids = var.cmk_encryption_enabled ? [azurerm_user_assigned_identity.identity[0].id] : null
  }

  key_vault_key_id = var.cmk_encryption_enabled ? azurerm_key_vault_key.kvkey[0].versionless_id : null


  tags = module.labels.tags

  depends_on = [
    time_sleep.wait_for_rbac
  ]
}

##----------------------------------------------------------------------------- 
## Private endpoint configuration 
##-----------------------------------------------------------------------------
resource "azurerm_private_endpoint" "pep" {
  count               = var.enabled && var.enable_private_endpoint ? 1 : 0
  name                = var.resource_position_prefix ? format("pe-cosmos-%s", local.name) : format("%s-pe-cosmos", local.name)
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = module.labels.tags

  private_dns_zone_group {
    name                 = var.resource_position_prefix ? format("dns-zone-group-cosmos-%s", local.name) : format("%s-dns-zone-group-cosmos", local.name)
    private_dns_zone_ids = [var.private_dns_zone_ids]
  }

  private_service_connection {
    name                           = format("cosmos-%s-connection", local.effective_api_type)
    is_manual_connection           = false
    private_connection_resource_id = azurerm_cosmosdb_account.db[0].id
    subresource_names              = [local.subresource_name] # Now handles all 6 APIs correctly
  }

  depends_on = [azurerm_cosmosdb_account.db]

  lifecycle {
    ignore_changes = [tags]
  }
}

##----------------------------------------------------------------------------- 
## Diagnostic settings for Cosmos DB monitoring
##-----------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "cosmosdb_law" {
  count                      = var.enabled && var.diagnostic_settings_enabled ? 1 : 0
  name                       = var.resource_position_prefix ? format("diag-cosmos-%s", local.name) : format("%s-diag-cosmos", local.name)
  target_resource_id         = azurerm_cosmosdb_account.db[0].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  # API-specific diagnostic logs
  dynamic "enabled_log" {
    for_each = local.diagnostic_logs # Uses deduplicated list
    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = var.diagnostic_metrics
    content {
      category = enabled_metric.value
    }
  }

  lifecycle {
    ignore_changes = [metric, enabled_log]
  }
}

##-----------------------------------------------------------------------------
## Timer: Wait for RBAC propagation before creating Cosmos DB
##----------------------------------------------------------------------------- 
resource "time_sleep" "wait_for_rbac" {
  create_duration = "60s" # Waits 60 seconds for permissions to sync

  # This ensures the timer starts ONLY after the role is assigned
  depends_on = [azurerm_role_assignment.identity_assigned]
}

##----------------------------------------------------------------------------- 
## Key Vault - Creates a key vault that will be used for encryption.  
##-----------------------------------------------------------------------------
resource "azurerm_key_vault_key" "kvkey" {
  depends_on      = [azurerm_role_assignment.identity_assigned, azurerm_role_assignment.rbac_keyvault_crypto_officer]
  count           = var.enabled && var.cmk_encryption_enabled ? 1 : 0
  name            = var.resource_position_prefix ? format("kvk-%s", local.name) : format("%s-kvk", local.name)
  expiration_date = var.expiration_date
  key_vault_id    = var.key_vault_id
  key_type        = var.key_type
  key_size        = var.key_size
  tags            = module.labels.tags
  key_opts        = var.key_opts

  dynamic "rotation_policy" {
    for_each = var.rotation_policy_enabled ? var.rotation_policy : {}
    content {
      automatic {
        time_before_expiry = rotation_policy.value.time_before_expiry
      }

      expire_after         = rotation_policy.value.expire_after
      notify_before_expiry = rotation_policy.value.notify_before_expiry
    }
  }
}

##-------------------------------------------------------------------------------------
## User Assigned Identity - Create user assigned identity in your azure environment.     
##-------------------------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "identity" {
  count               = var.enabled && var.cmk_encryption_enabled ? 1 : 0
  location            = var.location
  name                = var.resource_position_prefix ? format("uai-%s", local.name) : format("%s-uai", local.name)
  resource_group_name = var.resource_group_name
  tags                = module.labels.tags
}

##-----------------------------------------------------------------------------------------------------------------------
## Below resource will assign 'Key Vault Crypto Service Encryption User' role to user assigned identity created above. 
##-----------------------------------------------------------------------------------------------------------------------
resource "azurerm_role_assignment" "identity_assigned" {
  depends_on           = [azurerm_user_assigned_identity.identity]
  count                = var.enabled && var.cmk_encryption_enabled && var.key_vault_rbac_auth_enabled ? 1 : 0
  principal_id         = azurerm_user_assigned_identity.identity[0].principal_id
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
}

##-------------------------------------------------------------------------------------------------------------
## Below resource will provide user access on key vault based on role base access in azure environment.
## if rbac is enabled then below resource will create. 
##-------------------------------------------------------------------------------------------------------------
resource "azurerm_role_assignment" "rbac_keyvault_crypto_officer" {
  for_each = toset(var.key_vault_rbac_auth_enabled && var.enabled && var.cmk_encryption_enabled ? var.admin_objects_ids : [])

  scope                = var.key_vault_id
  role_definition_name = "Key Vault Crypto Officer"
  principal_id         = each.value
}