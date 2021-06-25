resource "azurerm_virtual_network" "spoke" {
  name                = "${var.prefix}-vnet"
  address_space       = [var.address_space]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "hub-to-${azurerm_virtual_network.spoke.name}"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = var.hub_vnet_name
  remote_virtual_network_id = azurerm_virtual_network.spoke.id
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "${azurerm_virtual_network.spoke.name}-to-hub"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.spoke.name
  remote_virtual_network_id = var.hub_vnet_id
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_link" {
  for_each = var.private_link_dns_zone_names

  name                  = "${var.prefix}-dns-link-${each.key}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = each.value
  virtual_network_id    = azurerm_virtual_network.spoke.id
}
