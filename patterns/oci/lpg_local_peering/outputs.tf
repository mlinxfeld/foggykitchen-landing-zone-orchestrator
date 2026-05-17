output "compartment_ocid" {
  value = local.compartment_ocid
}

output "lpg_ids" {
  value = module.lpg.lpg_ids
}

output "vcn_ids" {
  value = {
    for vcn_key, mod in module.vcns : vcn_key => mod.vcn_id
  }
}

output "subnet_ids" {
  value = {
    for vcn_key, mod in module.vcns : vcn_key => mod.subnet_ids
  }
}

output "instance_private_ips" {
  value = {
    for instance_key, mod in module.compute : instance_key => mod.instance_private_ip
  }
}

output "instance_public_ips" {
  value = {
    for instance_key, mod in module.compute : instance_key => mod.instance_public_ip
  }
}

output "load_balancer_id" {
  value = try(module.load_balancer[0].load_balancer_id, null)
}

output "load_balancer_private_ips" {
  value = try(module.load_balancer[0].load_balancer_private_ips, [])
}
