resource "azurerm_private_endpoint" "fnapp" {
  name                = "${var.prefix}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [var.private_link_dns_zones["app_service"]]
  }

  private_service_connection {
    name                           = "${var.prefix}-plconnection"
    is_manual_connection           = false
    private_connection_resource_id = jsondecode(azurerm_resource_group_template_deployment.functionapp.output_content).appId.value
    subresource_names              = ["sites"]
  }
}

resource "azurerm_subnet" "vnet_integration" {
  name                 = var.subnet_name
  resource_group_name  = var.vnet_resource_group
  virtual_network_name = var.vnet_name
  address_prefixes     = [var.subnet_address_space]

  delegation {
    name = "app-service-delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

// TODO: Replace this with default BGP route
// NOTE: The route table and UDRs are only used here to setup forced-tunneling. Often, forced tunneling
// is configured via BGP, in which case, no routes are required for VNet Integration.
resource "azurerm_route_table" "vnet_integration" {
  name                = "${var.prefix}-routetable"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_route" "vnet_integration_default" {
  name                   = "default"
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.vnet_integration.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.firewall_ip_address
}

resource "azurerm_subnet_route_table_association" "vnet_integration" {
  subnet_id      = azurerm_subnet.vnet_integration.id
  route_table_id = azurerm_route_table.vnet_integration.id
}
