output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "hub_vnet_id" {
  value = module.hub_vnet.vnet_id
}

output "spoke_vnet_ids" {
  value = {
    for spoke_key, mod in module.spoke_vnets : spoke_key => mod.vnet_id
  }
}

output "subnet_ids" {
  value = {
    hub  = module.hub_vnet.subnet_ids
    app  = module.spoke_vnets["app"].subnet_ids
    data = module.spoke_vnets["data"].subnet_ids
  }
}

output "nat_public_ip" {
  value = try(module.nat_public_ip[0].ip_address, null)
}

output "bastion_name" {
  value = try(module.bastion[0].bastion_name, null)
}

output "route_table_ids" {
  value = try(module.routing[0].route_table_ids, {})
}

output "private_dns_zone_ids" {
  value = length(module.private_dns) > 0 ? merge([for _, mod in module.private_dns : mod.private_dns_zone_ids]...) : {}
}

output "vm_private_ips" {
  value = {
    for instance_key, mod in module.compute : instance_key => mod.vm_private_ip
  }
}

output "internal_load_balancer_private_ip" {
  value = try(module.internal_load_balancer[0].private_ip_address, null)
}
