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
