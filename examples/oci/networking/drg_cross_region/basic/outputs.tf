output "home_vcn_id" {
  value = module.landing_zone.home_vcn_id
}

output "peer_vcn_id" {
  value = module.landing_zone.peer_vcn_id
}

output "home_drg_id" {
  value = module.landing_zone.home_drg_id
}

output "peer_drg_id" {
  value = module.landing_zone.peer_drg_id
}

output "home_remote_peering_connection_ids" {
  value = module.landing_zone.home_remote_peering_connection_ids
}

output "peer_remote_peering_connection_ids" {
  value = module.landing_zone.peer_remote_peering_connection_ids
}
