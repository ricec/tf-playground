module "cogsvc_storage" {
  source                     = "../../modules/services/storage"
  resource_group_name        = azurerm_resource_group.example.name
  location                   = local.location
  alphanum_prefix            = local.prefix
  prefix                     = local.prefix
  private_endpoint_subnet_id = data.terraform_remote_state.main.outputs.private_endpoint_subnet_id
  private_link_dns_zones     = data.terraform_remote_state.main.outputs.private_link_dns_zone_ids
}
