data "azurerm_client_config" "current" {}

locals {
  vm_scale_set_name = "${var.resource_name_prefix}-vault"
}

# Create resource group
module "resource_group" {
  source = "./modules/resource_group"

  common_tags          = var.common_tags
  location             = var.location
  resource_name_prefix = var.resource_name_prefix
}

# Create key vault
module "key_vault" {
  source = "./modules/key_vault"

  certificate          = var.key_vault_cert
  common_tags          = var.common_tags
  resource_group       = module.resource_group.resource_group
  resource_name_prefix = var.resource_name_prefix
}

# Create virtual network
module "vnet" {
  source = "./modules/vnet"

  abs_address_prefix   = var.abs_address_prefix
  address_space        = var.address_space
  common_tags          = var.common_tags
  lb_address_prefix    = var.lb_address_prefix
  resource_group       = module.resource_group.resource_group
  resource_name_prefix = var.resource_name_prefix
  vault_address_prefix = var.vault_address_prefix
}

module "kms" {
  source = "./modules/kms"

  common_tags                      = var.common_tags
  key_vault_id                     = module.key_vault.key_vault_id
  resource_name_prefix             = var.resource_name_prefix
  user_supplied_key_vault_key_name = var.user_supplied_key_vault_key_name
}

module "license_storage" {
  source = "./modules/license_storage"

  common_tags            = var.common_tags
  key_vault_id           = module.key_vault.key_vault_id
  resource_name_prefix   = var.resource_name_prefix
  vault_license_filepath = var.vault_license_filepath
}

module "iam" {
  source = "./modules/iam"

  common_tags                  = var.common_tags
  key_vault_id                 = module.key_vault.key_vault_id
  resource_group               = module.resource_group.resource_group
  resource_name_prefix         = var.resource_name_prefix
  tenant_id                    = data.azurerm_client_config.current.tenant_id
  user_supplied_lb_identity_id = var.user_supplied_lb_identity_id
  user_supplied_vm_identity_id = var.user_supplied_vm_identity_id
}

module "user_data" {
  source = "./modules/user_data"

  key_vault_key_name          = module.kms.key_vault_key_name
  key_vault_name              = element(split("/", module.key_vault.key_vault_id), length(split("/", module.key_vault.key_vault_id)) - 1)
  key_vault_secret_id         = module.key_vault.key_vault_vm_tls_secret_id
  leader_tls_servername       = var.leader_tls_servername
  license_secret_id           = module.license_storage.license_secret_id
  resource_group              = module.resource_group.resource_group
  subscription_id             = data.azurerm_client_config.current.subscription_id
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  user_supplied_userdata_path = var.user_supplied_userdata_path
  vault_version               = var.vault_version
  vm_scale_set_name           = local.vm_scale_set_name
}

module "load_balancer" {
  source = "./modules/load_balancer"

  autoscale_max_capacity       = var.lb_autoscale_max_capacity
  autoscale_min_capacity       = var.lb_autoscale_min_capacity
  backend_ca_cert              = var.lb_backend_ca_cert
  backend_server_name          = var.leader_tls_servername
  common_tags                  = var.common_tags
  health_check_path            = var.health_check_path
  key_vault_ssl_cert_secret_id = module.key_vault.key_vault_ssl_cert_secret_id
  private_ip_address           = var.lb_private_ip_address
  resource_group               = module.resource_group.resource_group
  resource_name_prefix         = var.resource_name_prefix
  sku_capacity                 = var.lb_sku_capacity
  subnet_id                    = module.vnet.lb_subnet_id
  zones                        = var.zones

  identity_ids = [
    module.iam.lb_identity_id,
  ]
}

module "vm" {
  source = "./modules/vm"

  application_security_group_ids = module.vnet.vault_application_security_group_ids
  common_tags                    = var.common_tags
  health_check_path              = var.health_check_path
  instance_count                 = var.instance_count
  instance_type                  = var.instance_type
  resource_group                 = module.resource_group.resource_group
  resource_name_prefix           = var.resource_name_prefix
  user_supplied_source_image_id  = var.user_supplied_source_image_id
  scale_set_name                 = local.vm_scale_set_name
  ssh_public_key                 = var.ssh_public_key
  subnet_id                      = module.vnet.vault_subnet_id
  ultra_ssd_enabled              = var.ultra_ssd_enabled
  user_data                      = module.user_data.vault_userdata_base64_encoded
  zones                          = var.zones

  backend_address_pool_ids = [
    module.load_balancer.backend_address_pool_id,
  ]

  identity_ids = [
    module.iam.vm_identity_id,
  ]
}
