##-----------------------------------------------------------------------------
## Outputs
##-----------------------------------------------------------------------------
output "cosmos_account_id" {
  value       = azurerm_cosmosdb_account.db[0].id
  description = "ID of the Cosmos DB account."
}

output "cosmos_account_name" {
  value       = azurerm_cosmosdb_account.db[0].name
  description = "Name of the Cosmos DB account."
}

output "cosmos_account_endpoint" {
  value       = azurerm_cosmosdb_account.db[0].endpoint
  description = "Primary endpoint of the Cosmos DB account."
}

output "sql_database_name" {
  value       = length(azurerm_cosmosdb_sql_database.example) > 0 ? azurerm_cosmosdb_sql_database.example[0].name : null
  description = "SQL database name (if created)."
}

output "sql_container_name" {
  value       = length(azurerm_cosmosdb_sql_container.example) > 0 ? azurerm_cosmosdb_sql_container.example[0].name : null
  description = "SQL container name (if created)."
}

output "mongo_database_names" {
  value       = [for k, v in azurerm_cosmosdb_mongo_database.mongo_db : v.name]
  description = "Mongo databases created (if any)."
}

output "gremlin_database_name" {
  value       = length(azurerm_cosmosdb_gremlin_database.example) > 0 ? azurerm_cosmosdb_gremlin_database.example[0].name : null
  description = "Gremlin database name (if created)."
}

output "cassandra_keyspace_name" {
  value       = length(azurerm_cosmosdb_cassandra_keyspace.example) > 0 ? azurerm_cosmosdb_cassandra_keyspace.example[0].name : null
  description = "Cassandra keyspace name (if created)."
}

output "cosmos_account_read_endpoints" {
  value       = azurerm_cosmosdb_account.db[0].read_endpoints
  description = "Read endpoints of the Cosmos DB account."
}

output "cosmos_account_write_endpoints" {
  value       = azurerm_cosmosdb_account.db[0].write_endpoints
  description = "Write endpoints of the Cosmos DB account."
}

output "cosmos_account_identity" {
  value       = azurerm_cosmosdb_account.db[0].identity
  description = "Managed identity of the Cosmos DB account."
}

output "cosmos_account_consistency_policy" {
  value       = azurerm_cosmosdb_account.db[0].consistency_policy
  description = "Consistency policy of the Cosmos DB account."
}