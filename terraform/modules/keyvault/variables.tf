variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
variable "workload_identity_principal_id" {
  description = "Principal ID of the AKS workload managed identity"
  type        = string
}