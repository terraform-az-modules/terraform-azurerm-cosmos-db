
##-----------------------------------------------------------------------------
## Naming convention
##-----------------------------------------------------------------------------
variable "custom_name" {
  type        = string
  default     = null
  description = "Override default naming convention"
}

variable "resource_position_prefix" {
  type        = bool
  default     = true
  description = <<EOT
Controls the placement of the resource type keyword (e.g., "vnet", "ddospp") in the resource name.

- If true, the keyword is prepended: "vnet-core-dev".
- If false, the keyword is appended: "core-dev-vnet".

This helps maintain naming consistency based on organizational preferences.
EOT
}

##-----------------------------------------------------------------------------
## Labels
##-----------------------------------------------------------------------------
variable "name" {
  type        = string
  default     = null
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "location" {
  type        = string
  default     = null
  description = "The location/region where the virtual network is created. Changing this forces a new resource to be created."
}

variable "environment" {
  type        = string
  default     = null
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "managedby" {
  type        = string
  default     = "terraform-az-modules"
  description = "ManagedBy, eg 'terraform-az-modules'."
}

variable "label_order" {
  type        = list(string)
  default     = ["name", "environment", "location"]
  description = "The order of labels used to construct resource names or tags. If not specified, defaults to ['name', 'environment', 'location']."
}

variable "repository" {
  type        = string
  default     = "https://github.com/terraform-az-modules/terraform-azure-vnet"
  description = "Terraform current module repo"

  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^https://", var.repository))
    error_message = "The module-repo value must be a valid Git repo link."
  }
}

variable "deployment_mode" {
  type        = string
  default     = "terraform"
  description = "Specifies how the infrastructure/resource is deployed"
}

variable "extra_tags" {
  type        = map(string)
  default     = null
  description = "Variable to pass extra tags."
}

##-----------------------------------------------------------------------------
## Global Variables
##-----------------------------------------------------------------------------
variable "resource_group_name" {
  type        = string
  default     = null
  description = "A container that holds related resources for an Azure solution."
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Flag to control module creation. If false, module resources are not created."
}

variable "geo_location" {
  type = list(object({
    location          = string
    failover_priority = number
  }))
  default     = []
  description = "A list of geo locations for the Cosmos DB account."
}

variable "offer_type" {
  type        = string
  default     = "Standard"
  description = "The offer type for Cosmos DB, e.g. 'Standard'."
}

variable "kind" {
  type        = string
  default     = "GlobalDocumentDB"
  description = "The kind of Cosmos DB account to create. Possible values are GlobalDocumentDB, MongoDB, Parse, Gremlin, Cassandra, and Table."
}

variable "ip_range_filter" {
  type        = list(string)
  default     = ["55.0.1.0/24"]
  description = "A set of IP addresses or IP address ranges in CIDR form to be included as the allowed list of client IPs for the Cosmos DB account."
}

variable "free_tier_enabled" {
  type        = bool
  default     = false
  description = "Enable the Free Tier pricing option for this Cosmos DB account."
}

variable "analytical_storage_enabled" {
  type        = bool
  default     = false
  description = "Enable Analytical Storage option for this Cosmos DB account."
}

variable "automatic_failover_enabled" {
  type        = bool
  default     = false
  description = "Enable automatic failover for this Cosmos DB account."
}

variable "partition_merge_enabled" {
  type        = bool
  default     = false
  description = "Is partition merge on the Cosmos DB account enabled?"
}

variable "burst_capacity_enabled" {
  type        = bool
  default     = false
  description = "Enable burst capacity for this Cosmos DB account."
}

variable "public_network_access_enabled" {
  type        = bool
  default     = true
  description = "Whether or not public network access is allowed for this Cosmos DB account."
}

variable "capabilities" {
  type = list(object({
    name = string
  }))
  default     = []
  description = "The capabilities which should be enabled for this Cosmos DB account."
}

variable "is_virtual_network_filter_enabled" {
  type        = bool
  default     = false
  description = "Enables virtual network filtering for this Cosmos DB account."
}

# variable "multiple_write_locations_enabled" {
#   type        = bool
#   default     = false
#   description = "Enable multiple write locations for this Cosmos DB account."
# }

# variable "access_key_metadata_writes_enabled" {
#   type        = bool
#   default     = true
#   description = "Is write operations on metadata resources (databases, containers, throughput) via account keys enabled?"
# }

# variable "mongo_server_version" {
#   type        = string
#   default     = "4.2"
#   description = "The Server Version of a MongoDB account."
# }

variable "network_acl_bypass_for_azure_services" {
  type        = bool
  default     = false
  description = "If Azure services can bypass ACLs."
}

# variable "network_acl_bypass_ids" {
#   type        = list(string)
#   default     = []
#   description = "The list of resource Ids for Network ACL Bypass for this Cosmos DB account."
# }

# variable "local_authentication_disabled" {
#   type        = bool
#   default     = false
#   description = "Disable local authentication and ensure only MSI and AAD can be used exclusively for authentication."
# }

variable "identity" {
  type        = any
  default     = "SystemAssigned"
  description = "An identity block as defined below."
}

# variable "restore" {
#   type        = any
#   default     = {}
#   description = "A restore block as defined below."
# }

variable "minimal_tls_version" {
  type        = string
  default     = "Tls12"
  description = "The minimum TLS version that clients must use to connect to the Cosmos DB account."
}

# variable "create_mode" {
#   type        = string
#   default     = null
#   description = "The mode to create the Cosmos DB account. Possible values are 'Default' or 'Restore'."
# }

variable "consistency_level" {
  default     = "BoundedStaleness"
  type        = string
  description = "Consistency level for the Cosmos DB account."
}

variable "max_interval_in_seconds" {
  default     = 300
  type        = number
  description = "The maximum interval (in seconds) allowed between read requests for the Cosmos DB account."
}

variable "max_staleness_prefix" {
  default     = 100000
  type        = number
  description = "The maximum staleness prefix in Cosmos DB to determine how long a request can be stale."
}

variable "role_definition_name" {
  type        = string
  default     = "Network Contributor"
  description = "Role definition name for Azure role assignments (e.g., 'Network Contributor')."
}

variable "role_principal_id" {
  type        = string
  default     = ""
  description = "Principal ID for the role assignment (can be a user, group, or service principal)."
}

variable "delegated_management_subnet_id" {
  type        = string
  default     = ""
  description = "The resource ID of the delegated management subnet to associate with the Cosmos DB account.Used in cassandra cluster and datacenter."
}

variable "default_admin_password" {
  type        = string
  default     = "abcd1234"
  description = "The default admin password for the Cosmos DB account."
}

variable "virtual_network_id" {
  type        = string
  default     = ""
  description = "The resource ID of the virtual network to associate with the Cosmos DB account."
}

variable "local_authentication_method" {
  type        = string
  default     = "None"
  description = "The authentication method for local users, e.g., 'None', 'Password', or 'Active Directory'."
}

variable "hours_between_backups" {
  type        = number
  default     = 24
  description = "Number of hours between backups for the Cosmos DB account."
}

variable "repair_enabled" {
  type        = bool
  default     = true
  description = "Flag to enable repair for the Cosmos DB account."
}

variable "cassandra_version" {
  default     = 3.11
  type        = number
  description = "Version of Cassandra to use in the Cosmos DB account."
}

variable "timeouts" {
  type = list(object({
    create = string
    read   = string
    update = string
    delete = string
  }))
  default = [
    {
      create = "10m"
      read   = "5m"
      update = "10m"
      delete = "5m"
    }
  ]
  description = "Timeout settings for resource creation, update, and deletion."
}

variable "node_count" {
  default     = 3
  type        = number
  description = "The number of nodes for the Cosmos DB account."
}

variable "disk_count" {
  default     = 4
  type        = number
  description = "The number of disks associated with the Cosmos DB account."
}

variable "sku_name" {
  default     = "Standard_E16s_v5"
  type        = string
  description = "SKU name for the Cosmos DB account."
}

variable "availability_zones_enabled" {
  default     = true
  type        = bool
  description = "Enable or disable availability zones for the Cosmos DB account."
}

variable "disk_sku" {
  type        = string
  default     = "P30"
  description = "The SKU for the disk storage associated with the Cosmos DB account."
}

variable "throughput" {
  default     = 400
  type        = number
  description = "The throughput (RU/s) for the Cosmos DB account."
}

variable "max_throughput" {
  default     = 1000
  type        = number
  description = "Maximum throughput (RU/s) for the Cosmos DB account."
}

# variable "schema_columns" {
#   type = list(object({
#     name = string
#     type = string
#   }))
#   default = [
#     {
#       name = "test1"
#       type = "ascii"
#     },
#     {
#       name = "test2"
#       type = "int"
#     }
#   ]
#   description = "A list of columns for the schema, each with a name and type."
# }

# variable "partition_keys" {
#   type        = list(string)
#   default     = []
#   description = "A list of partition keys for the schema."
# }


variable "default_ttl" {
  default     = 1
  type        = number
  description = "The default TTL (time-to-live) for items in the Cosmos DB account."
}

variable "unique_key_path" {
  default     = []
  type        = list(string)
  description = "Paths for the unique key constraint."
}


variable "partition_key_version" {
  type        = number
  default     = 1
  description = "Version of the partition key for Cosmos DB schema."
}

variable "allowed_headers" {
  type        = list(string)
  default     = ["Content-Type", "Authorization"]
  description = "A list of headers that are allowed to be part of the cross-origin request."
}

# variable "allowed_methods" {
#   type        = list(string)
#   default     = ["GET", "POST", "OPTIONS"]
#   description = "A list of HTTP methods that are allowed to be executed by the origin. Valid options are DELETE, GET, HEAD, MERGE, POST, OPTIONS, PUT, or PATCH."
# }

variable "allowed_origins" {
  type        = list(string)
  default     = ["*"]
  description = "A list of origin domains that are allowed by CORS."
}

variable "exposed_headers" {
  type        = list(string)
  default     = ["Content-Type", "X-Custom-Header"]
  description = "A list of response headers that are exposed to CORS clients."
}

# variable "ignore_missing_vnet_service_endpoint" {
#   type        = bool
#   default     = false
#   description = "If true, adds the subnet as a virtual network rule even if the CosmosDB service endpoint is inactive. Defaults to false."
# }

variable "backup_type" {
  type        = string
  default     = "Periodic"
  description = "The type of the backup. Possible values are 'Continuous' and 'Periodic'. Migration from Periodic to Continuous is one-way."
}

# variable "backup_tier" {
#   type        = string
#   default     = null
#   description = "The continuous backup tier. Possible values are 'Continuous7Days' and 'Continuous30Days'."
# }

variable "interval_in_minutes" {
  type        = number
  default     = 60
  description = "The interval in minutes between two backups (60 to 1440). Defaults to 240."
}

variable "retention_in_hours" {
  type        = number
  default     = 8
  description = "The time in hours that each backup is retained (8 to 720). Defaults to 8."
}

variable "storage_redundancy" {
  type        = string
  default     = null
  description = "The type of backup residency. Possible values are 'Geo', 'Local', and 'Zone'. Defaults to 'Geo'."
}

# variable "default_ttl_in_sec" {
#   type        = number
#   default     = -1
#   description = "Default time to live in seconds for items in the collection. Use -1 for infinite TTL and 0 to disable TTL."
# }

# variable "index" {
#   type = object({
#     keys   = list(string)
#     unique = bool
#   })
#   default = {
#     keys   = ["_id"]
#     unique = false
#   }
#   description = "The index block for Cosmos DB Mongo Collection."
# }

# variable "shard_key" {
#   default     = "unique_key"
#   type        = string
#   description = "The shard key for the Cosmos DB Mongo Collection."
# }

variable "role_name" {
  default     = "test123"
  type        = string
  description = "The name of the role definition for Cosmos DB Mongo collection."
}

variable "privileges" {
  type = list(object({
    actions = list(string)
    resource = object({
      collection_name = string
      db_name         = string
    })
  }))
  default = [
    {
      actions = ["find", "insert"]
      resource = {
        collection_name = "my_collection"
        db_name         = "my_database"
      }
    }
  ]
  description = "A list of privileges that define actions and resources in Cosmos DB Mongo collection."
}

variable "username" {
  default     = "testuser"
  type        = string
  description = "The username for the Cosmos DB Mongo collection."
}

variable "password" {
  default     = "cricket2001#"
  type        = string
  description = "The password for the Cosmos DB Mongo collection."
}

variable "administrator_login_password" {
  type        = string
  default     = "H@Sh1CoR3!"
  description = "The password for the administrator login."
}

variable "coordinator_storage_quota_in_mb" {
  type        = number
  default     = 131072
  description = "The storage quota for the coordinator in megabytes."
}

variable "coordinator_vcore_count" {
  type        = number
  default     = 2
  description = "The number of vCores allocated to the coordinator."
}

variable "node_public_ip_access_enabled" {
  type        = bool
  default     = false
  description = "Indicates if public access is enabled on worker nodes."
}

variable "node_server_edition" {
  type        = string
  default     = "MemoryOptimized"
  description = "The edition of the node server. Possible values are BurstableGeneralPurpose, BurstableMemoryOptimized, GeneralPurpose, and MemoryOptimized."
}

variable "sql_version" {
  type    = number
  default = 15
  validation {
    condition     = contains([11, 12, 13, 14, 15, 16, 9.5], var.sql_version)
    error_message = "The PostgreSQL version must be one of the allowed values: 11, 12, 13, 14, 15, or 16."
  }
  description = "The major PostgreSQL version on the Azure Cosmos DB for PostgreSQL cluster. Possible values are 11, 12, 13, 14, 15, and 16."
}

variable "point_in_time_in_utc" {
  type        = string
  default     = "2024-11-05T00:00:00Z"
  description = "The date and time in UTC (ISO8601 format) for the Azure Cosmos DB for PostgreSQL cluster restore. Changing this forces a new resource to be created."
}

# variable "node_storage_quota_in_mb" {
#   type        = number
#   default     = 1048576
#   description = "The storage quota in MB on each worker node. Possible values are 32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4194304, 8388608, and 16777216."
#   validation {
#     condition     = contains([32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4194304, 8388608, 16777216, 13107, 32768], var.node_storage_quota_in_mb)
#     error_message = "The storage quota must be one of the allowed values: 32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4194304, 8388608, or 16777216."
#   }
# }

variable "node_storage_quota_in_mb" {
  type        = number
  default     = 1048576
  description = "The storage quota in MB on each worker node."

  validation {
    condition = contains(
      [
        32768,
        65536,
        131072,
        262144,
        524288,
        1048576,
        2097152,
        4194304,
        8388608,
        16777216
      ],
      var.node_storage_quota_in_mb
    )
    error_message = "The storage quota must be one of: 32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4194304, 8388608, or 16777216."
  }
}

variable "ha_enabled" {
  type        = bool
  default     = false
  description = "Is high availability enabled for the Azure Cosmos DB for PostgreSQL cluster? Defaults to false."
}

variable "citus_version" {
  type        = number
  default     = 11.1
  description = "The Citus extension version on the Azure Cosmos DB for PostgreSQL cluster."
}

variable "node_vcores" {
  type        = number
  default     = 2
  description = "The vCores count on each worker node. Possible values are 1, 2, 4, 8, 16, 32, 64, 96, and 104."
}

variable "maintenance_window" {
  type = object({
    day_of_week  = number
    start_hour   = number
    start_minute = number
  })
  default = {
    day_of_week  = 0
    start_hour   = 0
    start_minute = 0
  }
  description = "The maintenance window for Azure Cosmos DB for PostgreSQL cluster."
}

variable "coordinator_value" {
  type        = string
  default     = "on"
  description = "The coordinator configuration settings for PostgreSQL cluster."
}

variable "ip_ranges" {
  type = list(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  default = [
    {
      start_ip_address = "10.0.17.62"
      end_ip_address   = "10.0.17.64"
    }
  ]
  description = "List of IP ranges (start and end) for firewall rules"
}

# variable "index_policy" {
#   type = object({
#     indexing_mode  = string
#     included_paths = list(object({ path = string }))
#     excluded_paths = list(object({
#       path = string
#     }))
#   })
#   default = {
#     indexing_mode = "consistent"
#     included_paths = [
#       { path = "/*" },
#       { path = "/included/?" }
#     ]
#     excluded_paths = [
#       { path = "/excluded/?" }
#     ]
#   }
#   description = "Indexing policy configuration for the Cosmos DB collection."
# }

variable "unique_key" {
  type = object({
    paths = list(string)
  })
  default = {
    paths = ["/container/id"]
  }
  description = "Unique key configuration for the Cosmos DB collection."
}

variable "instance_count" {
  type        = number
  default     = 1
  description = "The number of Cosmos DB instances."
}

variable "instance_size" {
  type        = string
  default     = "Cosmos.D4s"
  description = "The size of the Cosmos DB instance."
}

variable "function_body" {
  type        = string
  default     = "function trigger() { console.log('Hello, world!'); }"
  description = "The body of the function in the trigger."
}

variable "user_object_id" {
  type        = string
  default     = ""
  description = "The ID of the Principal (User, Group or Service Principal) to assign the Role Definition to. Changing this forces a new resource to be created."
}

variable "permissions_data_actions" {
  type        = list(string)
  default     = ["Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/read"]
  description = "List of data actions for CosmosDB permissions."
}

variable "role_type" {
  type    = string
  default = "CustomRole"
}

variable "operation_type" {
  type        = string
  default     = "Delete"
  description = "The type of operation for the API request or custom role action."
}

variable "request_type" {
  type        = string
  default     = "Post"
  description = "The HTTP method type (e.g., Post, Get, Put, Delete) for the API request."
}

variable "postgres_replica_enable" {
  type        = bool
  default     = false
  description = "Enable it when you want to replicate your Main Postgres SQL"
}

# variable "virtual_network_rule" {
#   type = list(object({
#     id                                   = string
#     ignore_missing_vnet_service_endpoint = bool
#   }))
# }

variable "source_resource_id" {
  type        = string
  default     = null
  description = "ID PASS"
}

variable "gremlin_enable" {
  type        = bool
  default     = false
  description = "Enable Gremlin DataBase By Defaullt its True"
}

variable "postgresql_enable" {
  type        = bool
  default     = false
  description = "Enable Gremlin DataBase By Defaullt its True"
}

variable "cassandra_enable" {
  type        = bool
  default     = false
  description = "Enable Gremlin DataBase By Defaullt its True"
}

variable "mongodb_enable" {
  type        = bool
  default     = false
  description = "Enable Gremlin DataBase By Defaullt its True"
}

variable "enable_sql_database" {
  type        = bool
  default     = false
  description = "Enable Gremlin DataBase By Defaullt its True"
}

variable "sql_partition_key_paths" {
  type        = list(string)
  default     = ["/definition/id"]
  description = "Partition key paths for the Cosmos DB SQL container."
}

variable "sql_partition_key_version" {
  type        = number
  default     = 1
  description = "Partition key version for the Cosmos DB SQL container."
}

variable "partition_key_path" {
  type    = string
  default = "/Example"
}

variable "index_policy_settings" {
  type = object({
    indexing_automatic = bool
    indexing_mode      = string
    included_paths     = list(string)
    excluded_paths     = list(string)
  })
  default = {
    indexing_automatic = true
    indexing_mode      = "consistent"
    included_paths     = ["/*"]
    excluded_paths     = ["/\"_etag\"/?"]
  }
  description = "Indexing policy settings for the database"
}

# variable "unique_key_paths" {
#   type        = list(string)
#   default     = ["/definition/id1", "/definition/id2"]
#   description = "List of paths for unique keys in Cosmos DB"
# }

variable "conflict_resolution_mode" {
  type        = string
  default     = "LastWriterWins"
  description = "Conflict resolution mode for Cosmos DB"
}

variable "conflict_resolution_path" {
  type        = string
  default     = "/_ts"
  description = "Path to resolve conflicts for LastWriterWins mode"
}

variable "conflict_resolution_procedure" {
  type        = string
  default     = ""
  description = "Procedure to resolve conflicts for Custom mode"
}

variable "indexing_policy_settings" {
  type = object({
    sql_indexing_mode = string
    sql_included_path = string
    sql_excluded_path = string
  })
  default = {
    sql_indexing_mode = "consistent"
    sql_included_path = "/*"
    sql_excluded_path = "/excluded/*"
  }
  description = "Indexing policy settings for Cosmos DB"
}

# variable "cassandra_schema_settings" {
#   type = object({
#     column = map(object({
#       column_key_name = string
#       column_key_type = string
#     }))
#     partition_key = map(object({
#       partition_key_name = string
#     }))
#     cluster_key = optional(map(object({
#       cluster_key_name     = string
#       cluster_key_order_by = string
#     })))
#   })
#   default = {
#     column = {
#       columnone = {
#         column_key_name = "loadid"
#         column_key_type = "uuid"
#       }
#       columntwo = {
#         column_key_name = "machine"
#         column_key_type = "uuid"
#       }
#       columnthree = {
#         column_key_name = "mtime"
#         column_key_type = "int"
#       }
#     }
#     partition_key = {
#       partition_key_one = {
#         partition_key_name = "loadid"
#       }
#     }
#     cluster_key = null
#   }
#   description = "Schema settings for the Cassandra table"
# }

variable "cassandra_schema_settings" {
  type = object({
    column = list(object({
      column_key_name = string
      column_key_type = string
    }))
    partition_key = list(object({
      partition_key_name = string
    }))
    cluster_key = optional(list(object({
      cluster_key_name     = string
      cluster_key_order_by = string
    })), [])
  })

  default = {
    column = [
      { column_key_name = "loadid", column_key_type = "uuid" },
      { column_key_name = "machine", column_key_type = "uuid" },
      { column_key_name = "mtime", column_key_type = "int" }
    ]
    partition_key = [
      { partition_key_name = "loadid" }
    ]
    cluster_key = []
  }

  description = "Schema settings for the Cassandra table."
}

# variable "mongo_indexes" {
#   type = list(object({
#     mongo_index_keys   = list(string)
#     mongo_index_unique = optional(bool)
#   }))
#   default = [
#     {
#       mongo_index_keys   = ["_id"]
#       mongo_index_unique = true
#     },
#     {
#       mongo_index_keys   = ["unique_key", "name"]
#       mongo_index_unique = true
#     },
#     {
#       mongo_index_keys   = ["age"]
#       mongo_index_unique = false
#     }
#   ]
#   description = "List of MongoDB index definitions."
# }

# variable "virtual_network_rules" {
#   type = list(object({
#     id                                   = string
#     ignore_missing_vnet_service_endpoint = optional(bool)
#   }))
#   default     = null
#   description = "Configures the virtual network subnets allowed to access this Cosmos DB account"
# }

#-------------------

variable "mongo_server_version" {
  type        = string
  default     = "4.2"
  description = "MongoDB server version (3.2, 3.6, 4.0, 4.2, 5.0, 6.0)"
}

variable "backup_tier" {
  type        = string
  default     = "Continuous7Days"
  description = "Backup tier for Continuous mode: Continuous7Days or Continuous30Days"
  validation {
    condition     = contains(["Continuous7Days", "Continuous30Days"], var.backup_tier)
    error_message = "Backup tier must be Continuous7Days or Continuous30Days."
  }
}

variable "virtual_network_rule" {
  type = list(object({
    id                                   = string
    ignore_missing_vnet_service_endpoint = bool
  }))
  default     = []
  description = "List of virtual network rules for Cosmos DB"
}

variable "diagnostic_logs" {
  type        = list(string)
  default     = ["DataPlaneRequests", "ControlPlaneRequests"]
  description = "List of diagnostic log categories to enable"
}

variable "diagnostic_metrics" {
  type        = list(string)
  default     = ["Requests"]
  description = "List of diagnostic metrics to enable"
}

variable "enable_cors" {
  type        = bool
  default     = false
  description = "Enable CORS configuration"
}

# variable "allowed_origins" {
#   type        = list(string)
#   default     = []
#   description = "List of allowed origins for CORS"
# }

# variable "allowed_headers" {
#   type        = list(string)
#   default     = ["*"]
#   description = "List of allowed headers for CORS"
# }

variable "allowed_methods" {
  type        = list(string)
  default     = ["GET", "HEAD", "POST", "PUT", "DELETE", "PATCH"]
  description = "List of allowed HTTP methods for CORS"
}

# variable "exposed_headers" {
#   type        = list(string)
#   default     = []
#   description = "List of exposed headers for CORS"
# }

##-----------------------------------------------------------------------------
## Private Endpoint Variables
##-----------------------------------------------------------------------------
variable "enable_private_endpoint" {
  type        = bool
  default     = false
  description = "Flag to enable creation of private endpoint"
}

variable "enable_private_endpoint_pgsql" {
  type        = bool
  default     = false
  description = "Flag to enable creation of private endpoint"
}

variable "private_endpoint_subnet_id" {
  type        = string
  default     = null
  description = "The subnet ID to create the private endpoint in."
}

variable "private_dns_zone_ids" {
  type        = string
  default     = null
  description = "List of private DNS zone IDs to link with the private endpoint."
}

##-----------------------------------------------------------------------------
## Diagnostics Variables
##-----------------------------------------------------------------------------
variable "diagnostic_settings_enabled" {
  type        = bool
  default     = false
  description = "Flag to enable/disable diagnostic settings"
}

variable "log_analytics_workspace_id" {
  type        = string
  default     = null
  description = "The ID of the Log Analytics Workspace to send diagnostics to."
}

##-----------------------------------------------------------------------------
## Role Assignment Variables
##-----------------------------------------------------------------------------
variable "enable_role" {
  type        = bool
  default     = false
  description = "Flag to enable role assignment"
}

variable "mongodb_databases" {
  type = list(object({
    name           = string
    throughput     = optional(number, null)
    max_throughput = optional(number, null)
    collections = optional(list(object({
      name                   = string
      shard_key              = optional(string, "_id")
      throughput             = optional(number, null)
      max_throughput         = optional(number, null)
      default_ttl_seconds    = optional(number, null)
      analytical_storage_ttl = optional(number, null)
      indexes = optional(list(object({
        keys   = list(string)
        unique = optional(bool, false)
      })), [])
    })), [])
  }))
  default     = []
  description = "A list of Cosmos DB MongoDB databases and their collections"
}

##-----------------------------------------------------------------------------
## Role Assignment Variables
##-----------------------------------------------------------------------------
variable "enable_mongo_user" {
  type        = bool
  default     = false
  description = "Flag to enable mongo user creation"
}

##-----------------------------------------------------------------------------
## Identity
##-----------------------------------------------------------------------------
# variable "identity_type" {
#   description = "Specifies the type of Managed Service Identity that should be configured on this Storage Account. Possible values are `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned` (to enable both)."
#   type        = string
#   default     = "SystemAssigned"
# }

##-----------------------------------------------------------------------------
## Key Vault & CMK
##-----------------------------------------------------------------------------
variable "cmk_encryption_enabled" {
  type        = bool
  default     = false
  description = "Whether to create CMK or not"
}

variable "key_vault_id" {
  type    = string
  default = null
}

variable "expiration_date" {
  type        = string
  default     = "2034-10-22T18:29:59Z"
  description = "Expiration UTC datetime (Y-m-d'T'H:M:S'Z')"
}

variable "key_type" {
  type        = string
  default     = "RSA"
  description = "The type of key to use. Possible values are `RSA` and `RSA-HSM`."
}

variable "key_size" {
  type        = number
  default     = 2048
  description = "The size of the key in bits. Possible values are `2048`, `3072`, and `4096` for RSA and `256` and `384` for EC."
}

variable "key_opts" {
  type        = list(string)
  default     = ["encrypt", "decrypt", "wrapKey", "unwrapKey", "sign", "verify"]
  description = "A list of key operations that the key supports. Possible values are `encrypt`, `decrypt`, `wrapKey`, `unwrapKey`, `sign`, `verify`, `get`, `list`, `create`, `update`, `import`, `delete`, `recover`, and `backup`."
}

# variable "key_permissions" {
#   type        = list(string)
#   default     = ["Create", "Delete", "Get", "Purge", "Recover", "Update", "Get", "WrapKey", "UnwrapKey", "List", "Decrypt", "Sign", "Encrypt"]
#   description = "A list of key permissions to be applied for the key vault access policy. Possible values are `get`, `list`, `update`, `create`, `import`, `delete`, `recover`, `backup`, `restore`, `decrypt`, `encrypt`, `wrapKey`, `unwrapKey`, `sign`, and `verify`."
# }

# variable "secret_permissions" {
#   type        = list(string)
#   default     = ["Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge"]
#   description = "A list of secret permissions to be applied for the key vault access policy. Possible values are `get`, `list`, `set`, `delete`, `recover`, `backup`, `restore`, and `purge`."
# }

# variable "storage_permissions" {
#   type        = list(string)
#   default     = ["Get", "List"]
#   description = "A list of storage permissions to be applied for the key vault access policy. Possible values are `get`, `list`, `delete`, `set`, `update`, `regeneratekey`, `setsas`, and `listsas`."
# }

variable "admin_objects_ids" {
  description = "IDs of the objects that can do all operations on all keys, secrets and certificates."
  type        = list(string)
  default     = []
}

variable "rotation_policy_enabled" {
  type        = bool
  default     = false
  description = "Whether or not to enable rotation policy"
}

variable "rotation_policy" {
  type = map(object({
    time_before_expiry   = string
    expire_after         = string
    notify_before_expiry = string
  }))
  default = null
}

variable "key_vault_rbac_auth_enabled" {
  type        = bool
  default     = true
  description = "Specifies whether Role-Based Access Control (RBAC) is enabled for the Key Vault."
}