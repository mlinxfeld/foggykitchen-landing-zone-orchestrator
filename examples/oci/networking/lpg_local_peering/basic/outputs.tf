output "compartment_ocid" {
  value = module.landing_zone.compartment_ocid
}

output "lpg_ids" {
  value = module.landing_zone.lpg_ids
}

output "vcn_ids" {
  value = module.landing_zone.vcn_ids
}

output "subnet_ids" {
  value = module.landing_zone.subnet_ids
}

output "instance_private_ips" {
  value = module.landing_zone.instance_private_ips
}

output "instance_public_ips" {
  value = module.landing_zone.instance_public_ips
}

output "load_balancer_id" {
  value = module.landing_zone.load_balancer_id
}

output "load_balancer_private_ips" {
  value = module.landing_zone.load_balancer_private_ips
}
