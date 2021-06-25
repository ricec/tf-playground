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
