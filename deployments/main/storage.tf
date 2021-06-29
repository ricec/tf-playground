module "functions_storage" {
  source                     = "../../modules/services/storage"
  resource_group_name        = azurerm_resource_group.example.name
  location                   = local.location
  alphanum_prefix            = "${local.prefix}fn"
  prefix                     = "${local.prefix}-fn"
  private_endpoint_subnet_id = module.hub_network.private_endpoint_subnet_id
  private_link_dns_zones     = module.hub_network.private_link_dns_zone_ids
}

resource "azurerm_storage_share" "function_content" {
  name                 = "${local.prefix}-fn-content-share"
  storage_account_name = module.functions_storage.storage_account_name
}

resource "azurerm_key_vault_secret" "functions_storage_connection_string" {
  name         = "functions-storage"
  value        = "DefaultEndpointsProtocol=https;AccountName=${module.functions_storage.storage_account_name};AccountKey=${module.functions_storage.primary_access_key}"
  key_vault_id = module.functions_key_vault.key_vault_id

  depends_on = [azurerm_key_vault_access_policy.tf_service_account]
}
