output "aks_name" {
  value = module.aks.name
}

output "aks_kubernetes_version" {
  value = module.aks.kubernetes_version
}

output "acr_login_server" {
  value = module.acr.login_server
}

output "vnet_id" {
  value = module.networking.vnet_id
}

output "aks_subnet_id" {
  value = module.networking.subnet_id
}