output "resource_group_name" {
  value = module.landing_zone.resource_group_name
}

output "hub_vnet_id" {
  value = module.landing_zone.hub_vnet_id
}

output "spoke_vnet_ids" {
  value = module.landing_zone.spoke_vnet_ids
}

output "subnet_ids" {
  value = module.landing_zone.subnet_ids
}

output "storage_account_id" {
  value = module.landing_zone.storage_account_id
}

output "storage_account_name" {
  value = module.landing_zone.storage_account_name
}

output "private_endpoint_ids" {
  value = module.landing_zone.private_endpoint_ids
}

output "private_endpoint_private_ips" {
  value = module.landing_zone.private_endpoint_private_ips
}

output "private_dns_zone_ids" {
  value = module.landing_zone.private_dns_zone_ids
}
