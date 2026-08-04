variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "vnet_address_space" {
  type = list(string)
}

variable "subnet_name" {
  type = string
}

variable "subnet_address_prefixes" {
  type = list(string)
}

variable "acr_name" {
  type = string
}

variable "aks_name" {
  type = string
}

variable "aks_dns_prefix" {
  type = string
}

variable "aks_node_count" {
  type = number
}

variable "aks_vm_size" {
  type = string
}

variable "project" {
  type = string
}

variable "auto_scaling_enabled" {
  type = bool
}

variable "min_count" {
  type = number
}

variable "max_count" {
  type = number
}