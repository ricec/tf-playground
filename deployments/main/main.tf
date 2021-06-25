provider "azurerm" {
  features {}
}

locals {
  prefix   = "tftesting"
  location = "southcentralus"
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "${local.prefix}-rg"
  location = local.location
}

module "hub_network" {
  source                       = "../../modules/hub_network"
  resource_group_name = azurerm_resource_group.example.name
  location                     = local.location
  prefix                       = "${local.prefix}-hub"
  vnet_address_space           = "10.0.0.0/16"
}

module "functions_spoke" {
  source                      = "../../modules/spoke_network"
  resource_group_name         = azurerm_resource_group.example.name
  location                    = local.location
  prefix                      = "${local.prefix}-fn"
  address_space               = "10.1.0.0/16"
  hub_vnet_id                 = module.hub_network.vnet_id
  hub_vnet_name               = module.hub_network.vnet_name
  private_link_dns_zone_names = module.hub_network.private_link_dns_zone_names
}

module "functions_storage" {
  source                     = "../../modules/services/storage"
  resource_group_name        = azurerm_resource_group.example.name
  location                   = local.location
  alphanum_prefix            = "${local.prefix}fn"
  prefix                     = "${local.prefix}-fn"
  private_endpoint_subnet_id = module.hub_network.private_endpoint_subnet_id
  private_link_dns_zones     = module.hub_network.private_link_dns_zone_ids
}

module "functions_key_vault" {
  source                     = "../../modules/services/key_vault"
  resource_group_name        = azurerm_resource_group.example.name
  location                   = local.location
  prefix                     = "${local.prefix}-kv"
  private_endpoint_subnet_id = module.hub_network.private_endpoint_subnet_id
  private_link_dns_zones     = module.hub_network.private_link_dns_zone_ids
}

resource "azurerm_key_vault_access_policy" "tf_service_account" {
  key_vault_id = module.functions_key_vault.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get",
    "Set",
    "Delete",
    "Purge"
  ]
}

resource "azurerm_key_vault_secret" "functions_storage_connection_string" {
  name         = "functions-storage"
  value        = "DefaultEndpointsProtocol=https;AccountName=${module.functions_storage.storage_account_name};AccountKey=${module.functions_storage.primary_access_key}"
  key_vault_id = module.functions_key_vault.key_vault_id

  depends_on = [azurerm_key_vault_access_policy.tf_service_account]
}

module "function" {
  source                     = "../../modules/services/functions"
  resource_group_name        = azurerm_resource_group.example.name
  location                   = local.location
  prefix                     = "${local.prefix}-fn"
  vnet_resource_group        = azurerm_resource_group.example.name
  vnet_name                  = module.functions_spoke.vnet_name
  subnet_name                = "function123"
  subnet_address_space       = "10.1.1.0/24"
  private_endpoint_subnet_id = module.hub_network.private_endpoint_subnet_id
  private_link_dns_zones     = module.hub_network.private_link_dns_zone_ids
  firewall_ip_address        = module.hub_network.firewall_private_ip_address
  webjobs_storage_secret_uri = azurerm_key_vault_secret.functions_storage_connection_string.versionless_id
  storage_account_name       = module.functions_storage.storage_account_name
}

resource "azurerm_key_vault_access_policy" "functions_identity" {
  key_vault_id = module.functions_key_vault.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = module.function.function_app_identity

  secret_permissions = [
    "Get"
  ]
}
