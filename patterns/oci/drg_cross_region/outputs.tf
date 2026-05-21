output "compartment_ocid" {
  value = local.compartment_ocid
}

output "home_vcn_id" {
  value = module.vcn_home.vcn_id
}

output "peer_vcn_id" {
  value = module.vcn_peer.vcn_id
}

output "home_subnet_ids" {
  value = module.vcn_home.subnet_ids
}

output "peer_subnet_ids" {
  value = module.vcn_peer.subnet_ids
}

output "home_drg_id" {
  value = module.drg_home.drg_id
}

output "peer_drg_id" {
  value = module.drg_peer.drg_id
}

output "home_drg_attachment_ids" {
  value = module.drg_home.drg_attachment_ids
}

output "peer_drg_attachment_ids" {
  value = module.drg_peer.drg_attachment_ids
}

output "home_drg_route_table_ids" {
  value = module.drg_home.drg_route_table_ids
}

output "peer_drg_route_table_ids" {
  value = module.drg_peer.drg_route_table_ids
}

output "home_remote_peering_connection_ids" {
  value = module.drg_home.remote_peering_connection_ids
}

output "peer_remote_peering_connection_ids" {
  value = module.drg_peer.remote_peering_connection_ids
}

output "home_rpc_attachment_management_ids" {
  value = module.drg_home.rpc_attachment_management_ids
}

output "peer_rpc_attachment_management_ids" {
  value = module.drg_peer.rpc_attachment_management_ids
}
