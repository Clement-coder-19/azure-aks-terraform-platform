resource "azurerm_kubernetes_cluster" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix

  kubernetes_version = var.kubernetes_version

  default_node_pool {
    name                 = "system"
    node_count           = var.node_count
    vm_size              = var.vm_size
    vnet_subnet_id       = var.subnet_id
    auto_scaling_enabled = var.auto_scaling_enabled
    min_count            = var.min_count
    max_count            = var.max_count

    upgrade_settings {
        max_surge                     = "10%"
        drain_timeout_in_minutes     = 0
        node_soak_duration_in_minutes = 0
    }
}

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = var.environment
    Project     = var.project
  }

  network_profile {
    network_plugin = "azure"
    service_cidr   = "10.1.0.0/16"
    dns_service_ip = "10.1.0.10"
  }
}