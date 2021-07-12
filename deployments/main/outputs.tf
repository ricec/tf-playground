output "private_endpoint_subnet_id" {
  value = module.hub_network.private_endpoint_subnet_id
}

output "private_link_dns_zone_ids" {
  value = module.hub_network.private_link_dns_zone_ids
}
