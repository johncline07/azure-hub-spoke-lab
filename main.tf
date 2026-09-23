terraform {
  required_version = ">= 1.0"

  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstatejohncline07"
    container_name       = "tfstate"
    key                  = "hub-spoke-lab.tfstate"
    use_azuread_auth     = true
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "hub_spoke" {
  name     = "rg-hub-spoke-lab"
  location = "East US"
}