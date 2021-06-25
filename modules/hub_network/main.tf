resource "azurerm_virtual_network" "hub" {
  name                = "${var.prefix}-vnet"
  address_space       = [var.vnet_address_space]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "hub_firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [cidrsubnet(var.vnet_address_space, 8, 0)]
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = "private-endpoint-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [cidrsubnet(var.vnet_address_space, 8, 1)]

  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_private_dns_zone" "blob_private_link" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone" "table_private_link" {
  name                = "privatelink.table.core.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone" "queue_private_link" {
  name                = "privatelink.queue.core.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone" "file_private_link" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone" "app_service_private_link" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone" "key_vault_private_link" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
}

resource "null_resource" "dns_zones" {
  triggers = {
    blob = azurerm_private_dns_zone.blob_private_link.name
    table = azurerm_private_dns_zone.table_private_link.name
    queue = azurerm_private_dns_zone.queue_private_link.name
    file = azurerm_private_dns_zone.file_private_link.name
    app_service = azurerm_private_dns_zone.app_service_private_link.name
    key_vault = azurerm_private_dns_zone.key_vault_private_link.name
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_link" {
  for_each = null_resource.dns_zones.triggers

  name                  = "${var.prefix}-dns-link-${each.key}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = each.value
  virtual_network_id    = azurerm_virtual_network.hub.id
}
