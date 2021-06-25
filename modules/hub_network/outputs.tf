output "vnet_id" {
  value = azurerm_virtual_network.hub.id
}

output "vnet_name" {
  value = azurerm_virtual_network.hub.name
}

output "firewall_private_ip_address" {
  value = azurerm_firewall.hub.ip_configuration[0].private_ip_address
}

output "private_endpoint_subnet_id" {
  value = azurerm_subnet.private_endpoints.id
}

output "private_link_dns_zone_ids" {
  value = {
    blob = azurerm_private_dns_zone.blob_private_link.id
    table = azurerm_private_dns_zone.table_private_link.id
    queue = azurerm_private_dns_zone.queue_private_link.id
    file = azurerm_private_dns_zone.file_private_link.id
    app_service = azurerm_private_dns_zone.app_service_private_link.id
    key_vault = azurerm_private_dns_zone.key_vault_private_link.id
  }
}

output "private_link_dns_zone_names" {
  value = null_resource.dns_zones.triggers
}
