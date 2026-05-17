output "azure_resource_group_name" {
  value = module.landing_zone.azure_resource_group_name
}

output "azure_vnet_id" {
  value = module.landing_zone.azure_vnet_id
}

output "azure_subnet_ids" {
  value = module.landing_zone.azure_subnet_ids
}

output "azure_vm_private_ip" {
  value = module.landing_zone.azure_vm_private_ip
}

output "azure_express_route_circuit_id" {
  value = module.landing_zone.azure_express_route_circuit_id
}

output "azure_virtual_network_gateway_connection_id" {
  value = module.landing_zone.azure_virtual_network_gateway_connection_id
}

output "oci_vcn_id" {
  value = module.landing_zone.oci_vcn_id
}

output "oci_subnet_ids" {
  value = module.landing_zone.oci_subnet_ids
}

output "oci_vm_private_ip" {
  value = module.landing_zone.oci_vm_private_ip
}

output "oci_drg_id" {
  value = module.landing_zone.oci_drg_id
}

output "oci_virtual_circuit_id" {
  value = module.landing_zone.oci_virtual_circuit_id
}
