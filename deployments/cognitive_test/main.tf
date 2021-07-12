provider "azurerm" {
  features {}
}

locals {
  prefix   = "cogsvctesting"
  location = "southcentralus"
}

data "terraform_remote_state" "main" {
  backend = "local"

  config = {
    path = "../main/terraform.tfstate"
  }
}

resource "azurerm_resource_group" "example" {
  name     = "${local.prefix}-rg"
  location = local.location
}

module "cognitive_service" {
  source                     = "../../modules/services/cognitive_services"
  resource_group_name        = azurerm_resource_group.example.name
  location                   = local.location
  prefix                     = local.prefix
  kind                       = "FormRecognizer"
  custom_subdomain           = "${local.prefix}153424"
  allowed_fqdns              = [module.cogsvc_storage.primary_blob_host]
  private_endpoint_subnet_id = data.terraform_remote_state.main.outputs.private_endpoint_subnet_id
  private_link_dns_zones     = data.terraform_remote_state.main.outputs.private_link_dns_zone_ids
}

resource "azurerm_role_assignment" "cogsvc_storage_reader" {
  scope                = module.cogsvc_storage.storage_account_id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = module.cognitive_service.cognitive_account_identity_principal_id
}
