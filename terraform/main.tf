terraform {
  required_version = ">= 1.5.0"

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

resource "azurerm_resource_group" "main" {
  name     = "rg-aks-terraform"
  location = "polandcentral"
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-aks-terraform"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "aks" {
  name                 = "subnet-aks"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_container_registry" "main" {
  name                = "clementaksterraform"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = false
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-terraform-platform"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "aks-terraform-platform"

  default_node_pool {
    name                 = "system"
    node_count           = 1
    vm_size              = "Standard_D2s_v3"
    vnet_subnet_id       = azurerm_subnet.aks.id
    auto_scaling_enabled = true
    min_count            = 1
    max_count            = 2

    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }
  }
  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "dev"
    Project     = "aks-terraform-platform"
  }

  network_profile {
    network_plugin = "azure"
    service_cidr   = "10.1.0.0/16"
    dns_service_ip = "10.1.0.10"
  }
}

output "aks_name" {
  value = azurerm_kubernetes_cluster.main.name
}

output "aks_kubernetes_version" {
  value = azurerm_kubernetes_cluster.main.kubernetes_version
}

output "acr_login_server" {
  value = azurerm_container_registry.main.login_server
}