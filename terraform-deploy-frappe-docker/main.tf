terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.79.0"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = true
  features {}
}

resource "azurerm_resource_group" "frappe-docker" {
  name     = "frappe-docker-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "frappe-docker" {
  name                = "frappe-docker-network"
  resource_group_name = azurerm_resource_group.frappe-docker.name
  location            = azurerm_resource_group.frappe-docker.location
  address_space       = ["10.0.0.0/16"]
}
