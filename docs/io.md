## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_key\_metadata\_writes\_enabled | Whether access key metadata writes are enabled for the Cosmos DB account. | `bool` | `false` | no |
| admin\_objects\_ids | IDs of the objects that can do all operations on all keys, secrets and certificates. | `list(string)` | `[]` | no |
| administrator\_login\_password | The password for the administrator login. | `string` | `"H@Sh1CoR3!"` | no |
| allowed\_headers | A list of headers that are allowed to be part of the cross-origin request. | `list(string)` | <pre>[<br>  "Content-Type",<br>  "Authorization"<br>]</pre> | no |
| allowed\_methods | List of allowed HTTP methods for CORS | `list(string)` | <pre>[<br>  "GET",<br>  "HEAD",<br>  "POST",<br>  "PUT",<br>  "DELETE",<br>  "PATCH"<br>]</pre> | no |
| allowed\_origins | A list of origin domains that are allowed by CORS. | `list(string)` | <pre>[<br>  "*"<br>]</pre> | no |
| analytical\_storage\_enabled | Enable Analytical Storage option for this Cosmos DB account. | `bool` | `false` | no |
| automatic\_failover\_enabled | Enable automatic failover for this Cosmos DB account. | `bool` | `false` | no |
| availability\_zones\_enabled | Enable or disable availability zones for the Cosmos DB account. | `bool` | `true` | no |
| backup\_tier | Backup tier for Continuous mode: Continuous7Days or Continuous30Days | `string` | `"Continuous7Days"` | no |
| backup\_type | The type of the backup. Possible values are 'Continuous' and 'Periodic'. Migration from Periodic to Continuous is one-way. | `string` | `"Periodic"` | no |
| burst\_capacity\_enabled | Enable burst capacity for this Cosmos DB account. | `bool` | `false` | no |
| capabilities | The capabilities which should be enabled for this Cosmos DB account. | <pre>list(object({<br>    name = string<br>  }))</pre> | `[]` | no |
| cassandra\_enable | Enable Cassandra DataBase By Defaullt its True | `bool` | `false` | no |
| cassandra\_schema\_settings | Schema settings for the Cassandra table. | <pre>object({<br>    column = list(object({<br>      column_key_name = string<br>      column_key_type = string<br>    }))<br>    partition_key = list(object({<br>      partition_key_name = string<br>    }))<br>    cluster_key = optional(list(object({<br>      cluster_key_name     = string<br>      cluster_key_order_by = string<br>    })), [])<br>  })</pre> | <pre>{<br>  "cluster_key": [],<br>  "column": [<br>    {<br>      "column_key_name": "loadid",<br>      "column_key_type": "uuid"<br>    },<br>    {<br>      "column_key_name": "machine",<br>      "column_key_type": "uuid"<br>    },<br>    {<br>      "column_key_name": "mtime",<br>      "column_key_type": "int"<br>    }<br>  ],<br>  "partition_key": [<br>    {<br>      "partition_key_name": "loadid"<br>    }<br>  ]<br>}</pre> | no |
| cassandra\_version | Version of Cassandra to use in the Cosmos DB account. | `number` | `3.11` | no |
| citus\_version | The Citus extension version on the Azure Cosmos DB for PostgreSQL cluster. | `number` | `11.1` | no |
| cmk\_encryption\_enabled | Whether to create CMK or not | `bool` | `false` | no |
| conflict\_resolution\_mode | Conflict resolution mode for Cosmos DB | `string` | `"LastWriterWins"` | no |
| conflict\_resolution\_path | Path to resolve conflicts for LastWriterWins mode | `string` | `"/_ts"` | no |
| conflict\_resolution\_procedure | Procedure to resolve conflicts for Custom mode | `string` | `""` | no |
| consistency\_level | Consistency level for the Cosmos DB account. | `string` | `"BoundedStaleness"` | no |
| coordinator\_storage\_quota\_in\_mb | The storage quota for the coordinator in megabytes. | `number` | `131072` | no |
| coordinator\_vcore\_count | The number of vCores allocated to the coordinator. | `number` | `2` | no |
| custom\_name | Override default naming convention | `string` | `null` | no |
| default\_admin\_password | The default admin password for the Cosmos DB account. | `string` | `"abcd1234"` | no |
| default\_ttl | The default TTL (time-to-live) for items in the Cosmos DB account. | `number` | `1` | no |
| delegated\_management\_subnet\_id | The resource ID of the delegated management subnet to associate with the Cosmos DB account.Used in cassandra cluster and datacenter. | `string` | `""` | no |
| deployment\_mode | Specifies how the infrastructure/resource is deployed | `string` | `"terraform"` | no |
| diagnostic\_logs | List of diagnostic log categories to enable | `list(string)` | <pre>[<br>  "DataPlaneRequests",<br>  "ControlPlaneRequests"<br>]</pre> | no |
| diagnostic\_metrics | List of diagnostic metrics to enable | `list(string)` | <pre>[<br>  "Requests"<br>]</pre> | no |
| diagnostic\_settings\_enabled | Flag to enable/disable diagnostic settings | `bool` | `false` | no |
| disk\_count | The number of disks associated with the Cosmos DB account. | `number` | `4` | no |
| disk\_sku | The SKU for the disk storage associated with the Cosmos DB account. | `string` | `"P30"` | no |
| enable\_cassandra\_core | Enable Cassandra Core functionality | `bool` | `false` | no |
| enable\_cors | Enable CORS configuration | `bool` | `false` | no |
| enable\_mongo\_user | Flag to enable mongo user creation | `bool` | `false` | no |
| enable\_private\_endpoint | Flag to enable creation of private endpoint | `bool` | `false` | no |
| enable\_private\_endpoint\_pgsql | Flag to enable creation of private endpoint | `bool` | `false` | no |
| enable\_role | Flag to enable role assignment | `bool` | `false` | no |
| enable\_sql\_database | Enable SQL Database By Defaullt its True | `bool` | `false` | no |
| enabled | Flag to control module creation. If false, module resources are not created. | `bool` | `true` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `null` | no |
| expiration\_date | Expiration UTC datetime (Y-m-d'T'H:M:S'Z') | `string` | `"2034-10-22T18:29:59Z"` | no |
| exposed\_headers | A list of response headers that are exposed to CORS clients. | `list(string)` | <pre>[<br>  "Content-Type",<br>  "X-Custom-Header"<br>]</pre> | no |
| extra\_tags | Variable to pass extra tags. | `map(string)` | `null` | no |
| free\_tier\_enabled | Enable the Free Tier pricing option for this Cosmos DB account. | `bool` | `false` | no |
| function\_body | The body of the function in the trigger. | `string` | `"function trigger() { console.log('Hello, world!'); }"` | no |
| geo\_location | A list of geo locations for the Cosmos DB account. | <pre>list(object({<br>    location          = string<br>    failover_priority = number<br>  }))</pre> | `[]` | no |
| gremlin\_enable | Enable Gremlin DataBase By Defaullt its True | `bool` | `false` | no |
| ha\_enabled | Is high availability enabled for the Azure Cosmos DB for PostgreSQL cluster? Defaults to false. | `bool` | `false` | no |
| hours\_between\_backups | Number of hours between backups for the Cosmos DB account. | `number` | `24` | no |
| identity | An identity block as defined below. | `any` | `"SystemAssigned"` | no |
| index\_policy\_settings | Indexing policy settings for the database | <pre>object({<br>    indexing_automatic = bool<br>    indexing_mode      = string<br>    included_paths     = list(string)<br>    excluded_paths     = list(string)<br>  })</pre> | <pre>{<br>  "excluded_paths": [<br>    "/\"_etag\"/?"<br>  ],<br>  "included_paths": [<br>    "/*"<br>  ],<br>  "indexing_automatic": true,<br>  "indexing_mode": "consistent"<br>}</pre> | no |
| instance\_count | The number of Cosmos DB instances. | `number` | `1` | no |
| instance\_size | The size of the Cosmos DB instance. | `string` | `"Cosmos.D4s"` | no |
| interval\_in\_minutes | The interval in minutes between two backups (60 to 1440). Defaults to 240. | `number` | `60` | no |
| ip\_range\_filter | A set of IP addresses or IP address ranges in CIDR form to be included as the allowed list of client IPs for the Cosmos DB account. | `list(string)` | <pre>[<br>  "55.0.1.0/24"<br>]</pre> | no |
| ip\_ranges | List of IP ranges (start and end) for firewall rules | <pre>list(object({<br>    start_ip_address = string<br>    end_ip_address   = string<br>  }))</pre> | `[]` | no |
| is\_virtual\_network\_filter\_enabled | Enables virtual network filtering for this Cosmos DB account. | `bool` | `false` | no |
| key\_opts | A list of key operations that the key supports. Possible values are `encrypt`, `decrypt`, `wrapKey`, `unwrapKey`, `sign`, `verify`, `get`, `list`, `create`, `update`, `import`, `delete`, `recover`, and `backup`. | `list(string)` | <pre>[<br>  "encrypt",<br>  "decrypt",<br>  "wrapKey",<br>  "unwrapKey",<br>  "sign",<br>  "verify"<br>]</pre> | no |
| key\_size | The size of the key in bits. Possible values are `2048`, `3072`, and `4096` for RSA and `256` and `384` for EC. | `number` | `2048` | no |
| key\_type | The type of key to use. Possible values are `RSA` and `RSA-HSM`. | `string` | `"RSA"` | no |
| key\_vault\_id | n/a | `string` | `null` | no |
| key\_vault\_rbac\_auth\_enabled | Specifies whether Role-Based Access Control (RBAC) is enabled for the Key Vault. | `bool` | `true` | no |
| kind | The kind of Cosmos DB account to create. Possible values are GlobalDocumentDB, MongoDB, Parse, Gremlin, Cassandra, and Table. | `string` | `"GlobalDocumentDB"` | no |
| label\_order | The order of labels used to construct resource names or tags. If not specified, defaults to ['name', 'environment', 'location']. | `list(string)` | <pre>[<br>  "name",<br>  "environment",<br>  "location"<br>]</pre> | no |
| local\_authentication\_enabled | Whether local authentication is enabled for the Cosmos DB account. | `bool` | `false` | no |
| local\_authentication\_method | The authentication method for local users, e.g., 'None', 'Password', or 'Active Directory'. | `string` | `"None"` | no |
| location | The location/region where the virtual network is created. Changing this forces a new resource to be created. | `string` | `null` | no |
| log\_analytics\_workspace\_id | The ID of the Log Analytics Workspace to send diagnostics to. | `string` | `null` | no |
| maintenance\_window | The maintenance window for Azure Cosmos DB for PostgreSQL cluster. | <pre>object({<br>    day_of_week  = number<br>    start_hour   = number<br>    start_minute = number<br>  })</pre> | <pre>{<br>  "day_of_week": 0,<br>  "start_hour": 0,<br>  "start_minute": 0<br>}</pre> | no |
| managedby | ManagedBy, eg 'terraform-az-modules'. | `string` | `"terraform-az-modules"` | no |
| max\_interval\_in\_seconds | The maximum interval (in seconds) allowed between read requests for the Cosmos DB account. | `number` | `300` | no |
| max\_staleness\_prefix | The maximum staleness prefix in Cosmos DB to determine how long a request can be stale. | `number` | `100000` | no |
| max\_throughput | Maximum throughput (RU/s) for the Cosmos DB account. | `number` | `1000` | no |
| minimal\_tls\_version | The minimum TLS version that clients must use to connect to the Cosmos DB account. | `string` | `"Tls12"` | no |
| mongo\_server\_version | MongoDB server version (3.2, 3.6, 4.0, 4.2, 5.0, 6.0) | `string` | `"4.2"` | no |
| mongodb\_databases | A list of Cosmos DB MongoDB databases and their collections | <pre>list(object({<br>    name           = string<br>    throughput     = optional(number, null)<br>    max_throughput = optional(number, null)<br>    collections = optional(list(object({<br>      name                   = string<br>      shard_key              = optional(string, "_id")<br>      throughput             = optional(number, null)<br>      max_throughput         = optional(number, null)<br>      default_ttl_seconds    = optional(number, null)<br>      analytical_storage_ttl = optional(number, null)<br>      indexes = optional(list(object({<br>        keys   = list(string)<br>        unique = optional(bool, false)<br>      })), [])<br>    })), [])<br>  }))</pre> | `[]` | no |
| mongodb\_enable | Enable MongoDB DataBase By Defaullt its True | `bool` | `false` | no |
| name | Name  (e.g. `app` or `cluster`). | `string` | `null` | no |
| network\_acl\_bypass\_for\_azure\_services | If Azure services can bypass ACLs. | `bool` | `false` | no |
| node\_count | The number of nodes for the Cosmos DB account. | `number` | `3` | no |
| node\_public\_ip\_access\_enabled | Indicates if public access is enabled on worker nodes. | `bool` | `false` | no |
| node\_server\_edition | The edition of the node server. Possible values are BurstableGeneralPurpose, BurstableMemoryOptimized, GeneralPurpose, and MemoryOptimized. | `string` | `"MemoryOptimized"` | no |
| node\_storage\_quota\_in\_mb | The storage quota in MB on each worker node. | `number` | `1048576` | no |
| node\_vcores | The vCores count on each worker node. Possible values are 1, 2, 4, 8, 16, 32, 64, 96, and 104. | `number` | `2` | no |
| offer\_type | The offer type for Cosmos DB, e.g. 'Standard'. | `string` | `"Standard"` | no |
| operation\_type | The type of operation for the API request or custom role action. | `string` | `"Delete"` | no |
| partition\_key\_path | n/a | `string` | `"/Example"` | no |
| partition\_key\_version | Version of the partition key for Cosmos DB schema. | `number` | `1` | no |
| partition\_merge\_enabled | Is partition merge on the Cosmos DB account enabled? | `bool` | `false` | no |
| password | The password for the Cosmos DB Mongo collection. | `string` | `"cricket2001#"` | no |
| permissions\_data\_actions | List of data actions for CosmosDB permissions. | `list(string)` | <pre>[<br>  "Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/read"<br>]</pre> | no |
| point\_in\_time\_in\_utc | The date and time in UTC (ISO8601 format) for the Azure Cosmos DB for PostgreSQL cluster restore. Changing this forces a new resource to be created. | `string` | `"2024-11-05T00:00:00Z"` | no |
| postgres\_replica\_enable | Enable it when you want to replicate your Main Postgres SQL | `bool` | `false` | no |
| postgresql\_enable | Enable PostgreSQL DataBase By Defaullt its True | `bool` | `false` | no |
| postgresql\_node\_configurations | A map of PostgreSQL node configurations (key = configuration name, value = configuration value). | `map(string)` | `{}` | no |
| private\_dns\_zone\_ids | List of private DNS zone IDs to link with the private endpoint. | `string` | `null` | no |
| private\_endpoint\_subnet\_id | The subnet ID to create the private endpoint in. | `string` | `null` | no |
| privileges | A list of privileges that define actions and resources in Cosmos DB Mongo collection. | <pre>list(object({<br>    actions = list(string)<br>    resource = object({<br>      collection_name = string<br>      db_name         = string<br>    })<br>  }))</pre> | <pre>[<br>  {<br>    "actions": [<br>      "find",<br>      "insert"<br>    ],<br>    "resource": {<br>      "collection_name": "my_collection",<br>      "db_name": "my_database"<br>    }<br>  }<br>]</pre> | no |
| public\_network\_access\_enabled | Whether or not public network access is allowed for this Cosmos DB account. | `bool` | `true` | no |
| repair\_enabled | Flag to enable repair for the Cosmos DB account. | `bool` | `true` | no |
| repository | Terraform current module repo | `string` | `"https://github.com/terraform-az-modules/terraform-azure-vnet"` | no |
| request\_type | The HTTP method type (e.g., Post, Get, Put, Delete) for the API request. | `string` | `"Post"` | no |
| resource\_group\_name | A container that holds related resources for an Azure solution. | `string` | `null` | no |
| resource\_position\_prefix | Controls the placement of the resource type keyword (e.g., "vnet", "ddospp") in the resource name.<br><br>- If true, the keyword is prepended: "vnet-core-dev".<br>- If false, the keyword is appended: "core-dev-vnet".<br><br>This helps maintain naming consistency based on organizational preferences. | `bool` | `true` | no |
| retention\_in\_hours | The time in hours that each backup is retained (8 to 720). Defaults to 8. | `number` | `8` | no |
| role\_definition\_name | Role definition name for Azure role assignments (e.g., 'Network Contributor'). | `string` | `"Network Contributor"` | no |
| role\_name | The name of the role definition for Cosmos DB Mongo collection. | `string` | `"test123"` | no |
| role\_principal\_id | Principal ID for the role assignment (can be a user, group, or service principal). | `string` | `""` | no |
| role\_type | n/a | `string` | `"CustomRole"` | no |
| rotation\_policy | n/a | <pre>map(object({<br>    time_before_expiry   = string<br>    expire_after         = string<br>    notify_before_expiry = string<br>  }))</pre> | `null` | no |
| rotation\_policy\_enabled | Whether or not to enable rotation policy | `bool` | `false` | no |
| sku\_name | SKU name for the Cosmos DB account. | `string` | `"Standard_E16s_v5"` | no |
| source\_resource\_id | ID PASS | `string` | `null` | no |
| sql\_indexing\_policy\_settings | Indexing policy settings for Cosmos DB | <pre>object({<br>    sql_indexing_mode = string<br>    sql_included_path = string<br>    sql_excluded_path = string<br>  })</pre> | <pre>{<br>  "sql_excluded_path": "/excluded/*",<br>  "sql_included_path": "/*",<br>  "sql_indexing_mode": "consistent"<br>}</pre> | no |
| sql\_partition\_key\_paths | Partition key paths for the Cosmos DB SQL container. | `list(string)` | <pre>[<br>  "/definition/id"<br>]</pre> | no |
| sql\_partition\_key\_version | Partition key version for the Cosmos DB SQL container. | `number` | `1` | no |
| sql\_version | The major PostgreSQL version on the Azure Cosmos DB for PostgreSQL cluster. Possible values are 11, 12, 13, 14, 15, and 16. | `number` | `15` | no |
| storage\_redundancy | The type of backup residency. Possible values are 'Geo', 'Local', and 'Zone'. Defaults to 'Geo'. | `string` | `null` | no |
| throughput | The throughput (RU/s) for the Cosmos DB account. | `number` | `400` | no |
| timeouts | Timeout settings for resource creation, update, and deletion. | <pre>list(object({<br>    create = string<br>    read   = string<br>    update = string<br>    delete = string<br>  }))</pre> | <pre>[<br>  {<br>    "create": "10m",<br>    "delete": "5m",<br>    "read": "5m",<br>    "update": "10m"<br>  }<br>]</pre> | no |
| unique\_key | Unique key configuration for the Cosmos DB collection. | <pre>object({<br>    paths = list(string)<br>  })</pre> | <pre>{<br>  "paths": [<br>    "/container/id"<br>  ]<br>}</pre> | no |
| unique\_key\_path | Paths for the unique key constraint. | `list(string)` | `[]` | no |
| user\_object\_id | The ID of the Principal (User, Group or Service Principal) to assign the Role Definition to. Changing this forces a new resource to be created. | `string` | `""` | no |
| username | The username for the Cosmos DB Mongo collection. | `string` | `"testuser"` | no |
| virtual\_network\_id | The resource ID of the virtual network to associate with the Cosmos DB account. | `string` | `""` | no |
| virtual\_network\_rule | List of virtual network rules for Cosmos DB | <pre>list(object({<br>    id                                   = string<br>    ignore_missing_vnet_service_endpoint = bool<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| cassandra\_keyspace\_name | Cassandra keyspace name (if created). |
| cosmos\_account\_consistency\_policy | Consistency policy of the Cosmos DB account. |
| cosmos\_account\_endpoint | Primary endpoint of the Cosmos DB account. |
| cosmos\_account\_id | ID of the Cosmos DB account. |
| cosmos\_account\_identity | Managed identity of the Cosmos DB account. |
| cosmos\_account\_name | Name of the Cosmos DB account. |
| cosmos\_account\_read\_endpoints | Read endpoints of the Cosmos DB account. |
| cosmos\_account\_write\_endpoints | Write endpoints of the Cosmos DB account. |
| gremlin\_database\_name | Gremlin database name (if created). |
| mongo\_database\_names | Mongo databases created (if any). |
| sql\_container\_name | SQL container name (if created). |
| sql\_database\_name | SQL database name (if created). |

