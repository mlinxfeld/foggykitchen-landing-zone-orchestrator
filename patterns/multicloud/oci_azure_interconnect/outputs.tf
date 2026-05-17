output "azure_resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "azure_vnet_id" {
  value = module.azure_vnet.vnet_id
}

output "azure_subnet_ids" {
  value = module.azure_vnet.subnet_ids
}

output "azure_vm_private_ip" {
  value = module.azure_compute.vm_private_ip
}

output "azure_express_route_service_key" {
  value     = azurerm_express_route_circuit.interconnect.service_key
  sensitive = true
}

output "azure_express_route_circuit_id" {
  value = azurerm_express_route_circuit.interconnect.id
}

output "azure_virtual_network_gateway_connection_id" {
  value = try(azurerm_virtual_network_gateway_connection.interconnect[0].id, null)
}

output "oci_vcn_id" {
  value = module.oci_vcn.vcn_id
}

output "oci_subnet_ids" {
  value = module.oci_vcn.subnet_ids
}

output "oci_vm_private_ip" {
  value = module.oci_compute.instance_private_ip
}

output "oci_drg_id" {
  value = oci_core_drg.interconnect.id
}

output "oci_virtual_circuit_id" {
  value = oci_core_virtual_circuit.interconnect.id
}
