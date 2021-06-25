resource "azurerm_api_management" "main" {
  name                 = "${var.prefix}-apim"
  location             = var.location
  resource_group_name  = var.existing_resource_group_name
  publisher_name       = var.publisher_name
  publisher_email      = var.publisher_email
  sku_name             = var.sku_name
  virtual_network_type = "Internal"

  virtual_network_configuration {
    subnet_id = azurerm_subnet.apim.id
  }
}
