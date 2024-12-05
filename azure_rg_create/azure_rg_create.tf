provider "azurerm" {
  features {}
  subscription_id = trimspace(file("../cloud_secrets/azure_subscription_id.txt"))
}

resource "azurerm_resource_group" "name" {
  name = "demo-rg-terraform"
  location = "North Europe"
}