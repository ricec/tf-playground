variable "resource_group_name" {}
variable "location" {}
variable "prefix" {}
variable "private_endpoint_subnet_id" {}
variable "private_link_dns_zones" {
  type = map(string)
}
