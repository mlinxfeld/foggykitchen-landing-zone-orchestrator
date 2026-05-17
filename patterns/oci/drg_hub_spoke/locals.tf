locals {
  config        = yamldecode(file(var.payload_file))
  landing_zone  = local.config.landing_zone
  cloud         = local.config.cloud
  architecture  = local.config.architecture
  networking    = local.config.networking
  connectivity  = local.config.connectivity
  compute       = local.config.compute
  load_balancer = local.config.load_balancer

  payload_dir        = dirname(var.payload_file)
  compartment_ocid   = local.cloud.compartment_ocid
  tenancy_ocid       = try(local.cloud.tenancy_ocid, null)
  region             = local.cloud.region
  defined_tags       = try(local.landing_zone.defined_tags, {})
  freeform_tags      = try(local.landing_zone.freeform_tags, {})
  vcn_keys           = keys(local.networking.vcns)
  app_vcn_key        = "app"
  data_vcn_key       = "data"
  hub_vcn_key        = "hub"
  app_subnet_key     = "frontend"
  backend_subnet_key = "private"

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
          route_table_key            = try(subnet.route_table_key, "private")
          security_list_keys         = try(subnet.security_list_keys, ["private"])
        }
      }
    }
  }

  hub_cidr  = local.vcns[local.hub_vcn_key].cidr_blocks[0]
  app_cidr  = local.vcns[local.app_vcn_key].cidr_blocks[0]
  data_cidr = local.vcns[local.data_vcn_key].cidr_blocks[0]

  route_targets_by_vcn = {
    hub = {
      app  = local.app_cidr
      data = local.data_cidr
    }
    app = {
      hub  = local.hub_cidr
      data = local.data_cidr
    }
    data = {
      hub = local.hub_cidr
      app = local.app_cidr
    }
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
                description = "Allow SSH from hub management subnet."
                protocol    = "6"
                source      = local.vcns[local.hub_vcn_key].subnets["management"].cidr_block
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

  drg_route_tables = {
    hub = {
      display_name = "drg-rt-hub"
      route_rules = [
        {
          destination             = local.app_cidr
          destination_type        = "CIDR_BLOCK"
          next_hop_attachment_key = "app"
        },
        {
          destination             = local.data_cidr
          destination_type        = "CIDR_BLOCK"
          next_hop_attachment_key = "data"
        }
      ]
    }
    app = {
      display_name = "drg-rt-app"
      route_rules = [
        {
          destination             = local.hub_cidr
          destination_type        = "CIDR_BLOCK"
          next_hop_attachment_key = "hub"
        },
        {
          destination             = local.data_cidr
          destination_type        = "CIDR_BLOCK"
          next_hop_attachment_key = "data"
        }
      ]
    }
    data = {
      display_name = "drg-rt-data"
      route_rules = [
        {
          destination             = local.hub_cidr
          destination_type        = "CIDR_BLOCK"
          next_hop_attachment_key = "hub"
        },
        {
          destination             = local.app_cidr
          destination_type        = "CIDR_BLOCK"
          next_hop_attachment_key = "app"
        }
      ]
    }
  }

  drg_attachments = {
    for attachment_key, attachment in local.connectivity.drg.attachments : attachment_key => {
      vcn_id              = module.vcns[attachment.vcn_ref].vcn_id
      display_name        = "drg-attach-${attachment_key}"
      drg_route_table_key = attachment_key
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
