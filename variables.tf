variable "abs_address_prefix" {
  default     = "10.0.3.0/24"
  description = "Azure Bastion Service Virtual Network subnet address prefix (set to \"\" to disable ABS creation)"
  type        = string
}

variable "address_space" {
  default     = "10.0.0.0/16"
  description = "Virtual Network address space"
  type        = string
}

variable "common_tags" {
  default     = {}
  description = "(Optional) Map of common tags for all taggable resources"
  type        = map(string)
}

variable "health_check_path" {
  default     = "/v1/sys/health?activecode=200&standbycode=200&sealedcode=200&uninitcode=200"
  description = "The endpoint to check for Vault's health status"
  type        = string
}

variable "instance_count" {
  default     = 5
  description = "Number of Vault VMs to deploy in Scale Set"
  type        = number
}

variable "instance_type" {
  default     = "Standard_D2s_v3"
  description = "Scale Set VM SKU"
  type        = string
}

variable "key_vault_cert" {
  default     = filebase64("certificate-to-import.pfx")
  description = "Base64 encoded .pfx certificate file to be imported into key vault"
  type        = string
}

variable "key_vault_id" {
  description = "Azure Key Vault containing TLS certificates (will also be used to store Vault seal secret & license)"
  type        = string
}

variable "key_vault_vm_tls_secret_id" {
  type        = string
  description = "ID of Key Vault Secret where VM TLS cert bundle is stored"
}

variable "key_vault_ssl_cert_secret_id" {
  description = "Secret ID of Key Vault Certificate for load balancer SSL"
  type        = string
}

variable "lb_address_prefix" {
  default     = "10.0.2.0/24"
  description = "Load balancer Virtual Network subnet address prefix"
  type        = string
}

variable "lb_autoscale_max_capacity" {
  default     = null
  description = "(Optional) Autoscaling capacity unit cap for Application Gateway (ignored if lb_sku_capacity is provided)"
  type        = number
}

variable "lb_autoscale_min_capacity" {
  default     = 0
  description = "Autoscaling minimum capacity units for Application Gateway (ignored if lb_sku_capacity is provided)"
  type        = number
}

variable "lb_backend_ca_cert" {
  type        = string
  description = "PEM cert of Certificate Authority used to sign key in key_vault_vm_tls_secret_id"
}

variable "lb_private_ip_address" {
  default     = null
  description = "(Optional) Load balancer fixed IPv4 address"
  type        = string
}

variable "lb_sku_capacity" {
  default     = null
  description = "(Optional) Fixed (non-autoscaling) number of capacity units for Application Gateway (overrides lb_autoscale_min_capacity/lb_autoscale_max_capacity variables)"
  type        = number
}

variable "lb_subnet_id" {
  description = "Subnet where Vault Application Gateway will be deployed"
  type        = string
}

variable "leader_tls_servername" {
  type        = string
  description = "One of the DNS Subject Alternative Names on the cert in key_vault_vm_tls_secret_id"
}

# variable "resource_group" {
#   description = "Azure resource group in which resources will be deployed"

#   type = object({
#     name     = string
#     location = string
#     id       = string
#   })
# }

variable "resource_name_prefix" {
  description = "Prefix applied to resource names (e.g. providing \"dev\" will create a VM Scale Set named \"dev-vault\")"
  type        = string
}

variable "ssh_public_key" {
  default     = ""
  description = "Public key to use for SSH access to Vault instances"
  type        = string
}

variable "ssh_username" {
  default     = "azureuser"
  description = "SSH admin username for Vault instances"
  type        = string
}

variable "user_supplied_source_image_id" {
  default     = null
  description = "(Optional) Image ID for Vault instances. If provided, please ensure it will work with the default userdata config (assumes latest version of Ubuntu LTS). Otherwise, please provide your own custom userdata using the user_supplied_userdata_path variable."
  type        = string
}

variable "user_supplied_userdata_path" {
  default     = null
  description = "(Optional) File path to custom VM configuration (i.e. cloud-init config) being supplied by the user"
  type        = string
}

variable "user_supplied_lb_identity_id" {
  default     = null
  description = "(Optional) User-provided User Assigned Identity for the Application Gateway. The minimum permissions must match the defaults generated by the IAM submodule for TLS bundle retrieval."
  type        = string
}

variable "user_supplied_vm_identity_id" {
  default     = null
  description = "(Optional) User-provided User Assigned Identity for Vault servers. The minimum permissions must match the defaults generated by the IAM submodule for cloud auto-join and auto-unseal."
  type        = string
}

variable "user_supplied_key_vault_key_name" {
  default     = null
  description = "(Optional) User-provided Key Vault Key name. Providing this will disable the KMS submodule from generating a KMS key used for Vault auto-unseal."
  type        = string
}

variable "ultra_ssd_enabled" {
  default     = true
  description = "Enable VM scale set Ultra SSD data disks compatibility"
  type        = bool
}

variable "vault_address_prefix" {
  default     = "10.0.1.0/24"
  description = "VM Virtual Network subnet address prefix"
  type        = string
}

variable "vault_application_security_group_ids" {
  type        = list(string)
  description = "Application Security Group ID for Vault VMs"
}

variable "vault_license_filepath" {
  type        = string
  description = "Path to location of Vault license file"
}

variable "vault_version" {
  default     = "1.8.1"
  description = "Vault version"
  type        = string
}

variable "vault_subnet_id" {
  description = "Subnet where Vault will be deployed"
  type        = string
}

variable "zones" {
  description = "Azure availability zones for deployment"
  type        = list(string)

  default = [
    "1",
    "2",
    "3",
  ]
}
