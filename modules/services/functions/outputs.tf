output "function_app_id" {
  value = jsondecode(azurerm_resource_group_template_deployment.functionapp.output_content).appId.value
}

output "plan_id" {
  value = azurerm_app_service_plan.fn.id
}

output "function_app_identity" {
  value = jsondecode(azurerm_resource_group_template_deployment.functionapp.output_content).identityPrincipalId.value
}
