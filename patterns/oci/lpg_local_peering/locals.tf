locals {
  config        = yamldecode(file(var.payload_file))
  landing_zone  = local.config.landing_zone
  cloud         = local.config.cloud
  architecture  = local.config.architecture
  networking    = local.config.networking
  connectivity  = local.config.connectivity
  compute       = local.config.compute
  load_balancer = local.config.load_balancer

  payload_dir      = dirname(var.payload_file)
  compartment_ocid = local.cloud.compartment_ocid
  tenancy_ocid     = try(local.cloud.tenancy_ocid, null)
  defined_tags     = try(local.landing_zone.defined_tags, {})
  freeform_tags    = try(local.landing_zone.freeform_tags, {})

  left_vcn_key   = local.connectivity.lpg.vcn_1_ref
  right_vcn_key  = local.connectivity.lpg.vcn_2_ref
  app_vcn_key    = "app"
  data_vcn_key   = "data"
  app_subnet_key = "frontend"

  vcns = {
    for vcn_key, vcn in local.networking.vcns : vcn_key => {
      name        = vcn.name
      dns_label   = try(vcn.dns_label, null)
      cidr_blocks = vcn.cidr_blocks
      subnets = {
        for subnet_key, subnet in try(vcn.subnets, {}) : subnet_key => {
          name                       = subnet.name
          cidr_block                 = subnet.cidr
          dns_label                  = try(subnet.dns_label, null)
          prohibit_public_ip_on_vnic = try(subnet.prohibit_public_ip_on_vnic, true)
          prohibit_internet_ingress  = try(subnet.prohibit_internet_ingress, true)
          security_list_keys         = try(subnet.security_list_keys, ["private"])
        }
      }
    }
  }

  vcn_cidrs = {
    for vcn_key, vcn in local.vcns : vcn_key => vcn.cidr_blocks[0]
  }

  route_targets_by_vcn = {
    for vcn_key, _ in local.vcns : vcn_key => {
      for target_key, destination in local.vcn_cidrs : target_key => destination
      if target_key != vcn_key
    }
  }

  peer_vcn_key_by_vcn = {
    for vcn_key, _ in local.vcns : vcn_key => (
      vcn_key == local.left_vcn_key ? local.right_vcn_key : local.left_vcn_key
    )
  }

  vcn_module_inputs = {
    for vcn_key, vcn in local.vcns : vcn_key => {
      name            = vcn.name
      dns_label       = vcn.dns_label
      vcn_cidr_blocks = vcn.cidr_blocks
      security_lists = {
        private = {
          display_name = "sl-${vcn.name}-private"
          ingress_rules = concat(
            [
              {
                description = "Allow SSH from peer VCN."
                protocol    = "6"
                source      = local.vcn_cidrs[local.peer_vcn_key_by_vcn[vcn_key]]
                source_type = "CIDR_BLOCK"
                tcp_options = {
                  min = 22
                  max = 22
                }
              }
            ],
            vcn_key == local.app_vcn_key ? [
              {
                description = "Allow application traffic from app frontend subnet."
                protocol    = "6"
                source      = local.vcns[local.app_vcn_key].subnets["frontend"].cidr_block
                source_type = "CIDR_BLOCK"
                tcp_options = {
                  min = local.load_balancer.listener.port
                  max = local.load_balancer.listener.port
                }
              }
            ] : []
          )
          egress_rules = [
            {
              description      = "Allow all egress."
              protocol         = "all"
              destination      = "0.0.0.0/0"
              destination_type = "CIDR_BLOCK"
            }
          ]
        }
      }
      subnets = {
        for subnet_key, subnet in vcn.subnets : subnet_key => {
          cidr_block                    = subnet.cidr_block
          display_name                  = subnet.name
          dns_label                     = subnet.dns_label
          security_list_keys            = subnet.security_list_keys
          include_default_security_list = false
          prohibit_internet_ingress     = subnet.prohibit_internet_ingress
          prohibit_public_ip_on_vnic    = subnet.prohibit_public_ip_on_vnic
          defined_tags                  = local.defined_tags
          freeform_tags                 = local.freeform_tags
        }
      }
    }
  }

  compute_instances = {
    for instance_key, instance in try(local.compute.instances, {}) : instance_key => {
      name                     = instance.name
      vcn_ref                  = instance.vcn_ref
      subnet_ref               = instance.subnet_ref
      shape                    = instance.shape
      ocpus                    = try(instance.ocpus, null)
      memory_in_gbs            = try(instance.memory_in_gbs, null)
      assign_public_ip         = try(instance.public_ip, false)
      operating_system         = try(instance.operating_system, "Oracle Linux")
      operating_system_version = try(instance.operating_system_version, "9")
      user_data                = try(instance.cloud_init, null) != null ? filebase64("${local.payload_dir}/${instance.cloud_init}") : null
    }
  }

  load_balancer_backend_refs = toset(try(local.load_balancer.backend_instance_refs, []))
}
