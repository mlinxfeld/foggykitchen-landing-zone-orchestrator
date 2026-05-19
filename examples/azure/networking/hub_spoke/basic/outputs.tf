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

output "nat_public_ip" {
  value = module.landing_zone.nat_public_ip
}

output "bastion_name" {
  value = module.landing_zone.bastion_name
}
