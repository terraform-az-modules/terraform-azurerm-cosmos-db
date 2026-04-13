##-----------------------------------------------------------------------------
## Locals
##-----------------------------------------------------------------------------
locals {
  name = var.custom_name != null ? var.custom_name : module.labels.id

  # Detect actual API type from kind + capabilities [web:66]
  has_gremlin_capability   = contains([for c in var.capabilities : c.name], "EnableGremlin")
  has_cassandra_capability = contains([for c in var.capabilities : c.name], "EnableCassandra")
  has_table_capability     = contains([for c in var.capabilities : c.name], "EnableTable")

  # Determine effective API type
  effective_api_type = (
    var.kind == "MongoDB" ? "MongoDB" :
    var.kind == "Parse" ? "Table" :
    local.has_gremlin_capability ? "Gremlin" :
    local.has_cassandra_capability ? "Cassandra" :
    local.has_table_capability ? "Table" :
    "Sql" # Default to SQL for GlobalDocumentDB without special capabilities
  )

  # Map effective API type to private endpoint subresource name
  subresource_mapping = {
    "Sql"       = "Sql"
    "MongoDB"   = "MongoDB"
    "Cassandra" = "Cassandra"
    "Gremlin"   = "Gremlin"
    "Table"     = "Table"
  }

  subresource_name = local.subresource_mapping[local.effective_api_type]

  # Base diagnostic logs common to all APIs (REMOVED MongoRequests from here)
  # base_diagnostic_logs = [
  #   "DataPlaneRequests",
  #   "ControlPlaneRequests",
  #   "PartitionKeyStatistics",
  #   "PartitionKeyRUConsumption"
  # ]

  # API-specific additional logs
  api_specific_logs = {
    "MongoDB"   = ["MongoRequests"]
    "Sql"       = ["QueryRuntimeStatistics", "PartitionKeyStatistics"]
    "Gremlin"   = ["GremlinRequests"]
    "Cassandra" = ["CassandraRequests"]
    "Table"     = ["TableApiRequests"]
  }

  # Combine base + API-specific logs (no duplicates now)
  diagnostic_logs = distinct(concat(
    var.diagnostic_logs,
    lookup(local.api_specific_logs, local.effective_api_type, [])
  ))

  # API-specific capabilities to auto-inject
  api_capabilities = {
    "MongoDB"   = [{ name = "EnableMongo" }, { name = "EnableMongoRoleBasedAccessControl" }]
    "Gremlin"   = [{ name = "EnableGremlin" }]
    "Cassandra" = [{ name = "EnableCassandra" }]
    "Table"     = [{ name = "EnableTable" }]
  }

  # Merge user capabilities with API-required capabilities
  merged_capabilities = distinct(concat(
    var.capabilities,
    lookup(local.api_capabilities, local.effective_api_type, [])
  ))
}
