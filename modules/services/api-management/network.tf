resource "azurerm_subnet" "apim" {
  name                 = var.subnet_name
  resource_group_name  = var.existing_vnet_resource_group
  virtual_network_name = var.existing_vnet_name
  address_prefixes     = [var.subnet_address_space]

  delegation {
    name = "apim-delegation"

    service_delegation {
      name = "Microsoft.ApiManagement/service"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"
      ]
    }
  }
}

resource "azurerm_route_table" "apim" {
  name                = "${var.prefix}-apim-routetable"
  location            = var.location
  resource_group_name = var.existing_resource_group_name
}

// TODO: Replace this with default BGP route
resource "azurerm_route" "apim_default" {
  name                   = "default"
  resource_group_name    = var.existing_resource_group_name
  route_table_name       = azurerm_route_table.apim.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.firewall_ip_address
}

resource "azurerm_route" "apim_mgmt" {
  name                = "apim-mgmt"
  resource_group_name = var.existing_resource_group_name
  route_table_name    = azurerm_route_table.apim.name
  address_prefix      = "ApiManagement"
  next_hop_type       = "Internet"
}

resource "azurerm_subnet_route_table_association" "apim" {
  subnet_id      = azurerm_subnet.apim.id
  route_table_id = azurerm_route_table.apim.id
}
