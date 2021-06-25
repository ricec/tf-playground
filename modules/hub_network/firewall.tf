resource "azurerm_public_ip" "hub_firewall" {
  name                = "${var.prefix}-firewall-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "hub" {
  name                = "${var.prefix}-firewall"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                 = "primary-ipconfig"
    subnet_id            = azurerm_subnet.hub_firewall.id
    public_ip_address_id = azurerm_public_ip.hub_firewall.id
  }
}

resource "azurerm_firewall_network_rule_collection" "allow_all" {
  name                = "allow-all-collection"
  azure_firewall_name = azurerm_firewall.hub.name
  resource_group_name = var.resource_group_name
  priority            = 100
  action              = "Allow"

  rule {
    name                  = "AllowAll"
    source_addresses      = ["*"]
    destination_ports     = ["*"]
    destination_addresses = ["*"]

    protocols = [
      "TCP",
      "UDP"
    ]
  }
}
