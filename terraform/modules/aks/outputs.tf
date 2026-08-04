output "id" {
  value = azurerm_kubernetes_cluster.main.id
}

output "name" {
  value = azurerm_kubernetes_cluster.main.name
}

output "kubernetes_version" {
  value = azurerm_kubernetes_cluster.main.kubernetes_version
}

output "node_resource_group" {
  value = azurerm_kubernetes_cluster.main.node_resource_group
}