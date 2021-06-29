variable "resource_group_name" {}
variable "location" {}
variable "prefix" {}
variable "vnet_resource_group" {}
variable "vnet_name" {}
variable "subnet_name" {}
variable "subnet_address_space" {}
variable "private_endpoint_subnet_id" {}
variable "private_link_dns_zones" {
  type = map(string)
}

// TODO: Remove this. Replace with BGP?
variable "firewall_ip_address" {}

variable "webjobs_storage_secret_uri" {}
variable "storage_account_name" {} 
variable "storage_content_share_name" {}
