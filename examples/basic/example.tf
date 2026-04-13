provider "azurerm" {
  features {}
}

module "cosmos-db" {
  source = "../../"
}
