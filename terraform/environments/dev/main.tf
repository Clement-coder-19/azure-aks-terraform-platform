terraform {
  required_version = ">= 1.5.0"

  backend "azurerm" {
    resource_group_name  = "rg-aks-terraform"
    storage_account_name = "tfstateclementaks"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
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

  resource_provider_registrations = "none"
}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

module "networking" {
  source = "../../modules/networking"

  resource_group_name     = data.azurerm_resource_group.main.name
  location                = data.azurerm_resource_group.main.location
  vnet_name               = var.vnet_name
  vnet_address_space      = var.vnet_address_space
  subnet_name             = var.subnet_name
  subnet_address_prefixes = var.subnet_address_prefixes
}

module "acr" {
  source = "../../modules/acr"

  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  name                = var.acr_name
  sku                 = "Basic"
}

module "aks" {
  source = "../../modules/aks"

  name                = var.aks_name
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  dns_prefix          = var.aks_dns_prefix

  subnet_id  = module.networking.subnet_id
  node_count = var.aks_node_count
  vm_size    = var.aks_vm_size

  auto_scaling_enabled = var.auto_scaling_enabled
  min_count             = var.min_count
  max_count             = var.max_count

  environment = var.environment
  project     = var.project
}