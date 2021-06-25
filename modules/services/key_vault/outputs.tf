output "key_vault_id" {
  value = azurerm_key_vault.main.id

  depends_on = [
    azurerm_private_endpoint.kv
  ]
}
