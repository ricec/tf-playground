variable "resource_group_name" {}
variable "location" {}
variable "prefix" {}
variable "address_space" {}
variable "hub_vnet_id" {}
variable "hub_vnet_name" {}
variable "private_link_dns_zone_names" {
  type = map(string)
}
