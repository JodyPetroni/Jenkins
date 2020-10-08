terraform {
  backend "azurerm" {
    resource_group_name  = "terraform"
    storage_account_name = "terrastatestoragejmp"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  version = "~>2.20.0"
}

module "rg" {
  source      = "./src"
}
