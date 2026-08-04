variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "dns_prefix" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "node_count" {
  type = number
}

variable "vm_size" {
  type = string
}

variable "kubernetes_version" {
  type    = string
  default = null
}

variable "environment" {
  type = string
}

variable "project" {
  type = string
}
variable "auto_scaling_enabled" {
  type    = bool
  default = true
}

variable "min_count" {
  type    = number
  default = 1
}

variable "max_count" {
  type    = number
  default = 2
}