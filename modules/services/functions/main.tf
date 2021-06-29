resource "azurerm_app_service_plan" "fn" {
  name                = "${var.prefix}-plan"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "elastic"

  sku {
    tier = "ElasticPremium"
    size = "EP1"
  }
}


// WORKAROUND: Temporarily leverage ARM templates for the following capabilities:
// - Ability to set siteconfig.vnetRouteAllEnabled = true
// - Ability to setup VNet Integration at Function App creation via virtualNetworkSubnetId
//
// NOTE: The ARM template explicitly sets WEBSITE_DNS_SERVER to point to Azure DNS resolvers.
// This is needed only when using Azure Private DNS Zones and should be removed if/when custom DNS is used.
resource "azurerm_resource_group_template_deployment" "functionapp" {
  name                = "${var.prefix}-fnappdeploy2"
  resource_group_name = var.resource_group_name
  deployment_mode     = "Incremental"
  template_content    = file("${path.module}/functionapp.json")

  parameters_content = jsonencode({
    "name" = { value = "${var.prefix}-fnapp" },
    "location" = { value = var.location }
    "runtime" = { value = "node" }
    "planId" = { value = azurerm_app_service_plan.fn.id }
    "subnetId" = { value = azurerm_subnet.vnet_integration.id }
    "storageAccountName" = { value = var.storage_account_name }
    "storageContentShare" = { value = var.storage_content_share_name }
    "webJobsStorageSecretUri" = { value = var.webjobs_storage_secret_uri }
  })
}
