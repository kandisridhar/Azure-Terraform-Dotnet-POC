terraform {
  required_version = ">= 0.11"
  /*required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.92.0"
    }
  }*/
  backend "azurerm" {
  storage_account_name = "__terraformstorageaccount__"
  container_name       = "__statefile-cont__"
  key                  = "terraform.tfstate"
	access_key           ="__storagekey__"
	}
}

provider "azurerm" {
  features {}

  /*subscription_id = "**************"
  client_id       = "**************"
  client_secret   = "**************"
  tenant_id       = "**************" */
}