data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                     = "${var.prefix}-vault"
  location                 = var.location
  resource_group_name      = var.resource_group_name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  sku_name                 = "standard"

  network_acls {
    bypass         = "AzureServices"
    //TODO: Change this to Deny. Only set to "Allow" because I need to allow from my home IP (which changes a lot).
    default_action = "Allow"
  }
}

resource "azurerm_private_endpoint" "kv" {
  name                = "${var.prefix}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [var.private_link_dns_zones["key_vault"]]
  }

  private_service_connection {
    name                           = "${var.prefix}-plconnection"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_key_vault.main.id
    subresource_names              = ["Vault"]
  }
}
