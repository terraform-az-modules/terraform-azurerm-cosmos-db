##----------------------------------------------------------------------------- 
## Role assignment resource for managing access to a virtual network
##-----------------------------------------------------------------------------
resource "azurerm_role_assignment" "example" {
  count                = var.enabled && var.enable_role ? 1 : 0
  scope                = var.virtual_network_id
  role_definition_name = var.role_definition_name
  principal_id         = var.role_principal_id
}