locals {
  config       = yamldecode(file(var.payload_file))
  landing_zone = local.config.landing_zone
  cloud        = local.config.cloud
  architecture = local.config.architecture
  networking   = local.config.networking
  connectivity = local.config.connectivity

  compartment_ocid = local.cloud.compartment_ocid
  defined_tags     = try(local.landing_zone.defined_tags, {})
  freeform_tags    = try(local.landing_zone.freeform_tags, {})

  home = {
    region = local.cloud.home_region
    vcn    = local.networking.home.vcn
    drg    = local.connectivity.drg.home
  }

  peer = {
    region = local.cloud.peer_region
    vcn    = local.networking.peer.vcn
    drg    = local.connectivity.drg.peer
  }

  home_vcn_cidr = local.home.vcn.cidr_blocks[0]
  peer_vcn_cidr = local.peer.vcn.cidr_blocks[0]

  home_subnets = {
    for subnet_key, subnet in try(local.home.vcn.subnets, {}) : subnet_key => {
      display_name                  = subnet.name
      cidr_block                    = subnet.cidr
      dns_label                     = try(subnet.dns_label, null)
      route_table_key               = try(subnet.route_table_key, "private")
      security_list_keys            = try(subnet.security_list_keys, ["app"])
      prohibit_internet_ingress     = try(subnet.prohibit_internet_ingress, true)
      prohibit_public_ip_on_vnic    = try(subnet.prohibit_public_ip_on_vnic, true)
      include_default_security_list = false
    }
  }

  peer_subnets = {
    for subnet_key, subnet in try(local.peer.vcn.subnets, {}) : subnet_key => {
      display_name                  = subnet.name
      cidr_block                    = subnet.cidr
      dns_label                     = try(subnet.dns_label, null)
      route_table_key               = try(subnet.route_table_key, "private")
      security_list_keys            = try(subnet.security_list_keys, ["app"])
      prohibit_internet_ingress     = try(subnet.prohibit_internet_ingress, true)
      prohibit_public_ip_on_vnic    = try(subnet.prohibit_public_ip_on_vnic, true)
      include_default_security_list = false
    }
  }

  home_vcn_route_tables = {
    private = {
      display_name = local.home.vcn.route_tables.private.name
      route_rules = [
        {
          destination        = "0.0.0.0/0"
          destination_type   = "CIDR_BLOCK"
          network_entity_key = "nat_gateway"
        },
        {
          destination        = "all-services"
          destination_type   = "SERVICE_CIDR_BLOCK"
          network_entity_key = "service_gateway"
        },
        {
          description        = "Remote peer VCN through DRG"
          destination        = local.peer_vcn_cidr
          destination_type   = "CIDR_BLOCK"
          network_entity_key = "drg"
        }
      ]
    }
  }

  peer_vcn_route_tables = {
    private = {
      display_name = local.peer.vcn.route_tables.private.name
      route_rules = [
        {
          destination        = "0.0.0.0/0"
          destination_type   = "CIDR_BLOCK"
          network_entity_key = "nat_gateway"
        },
        {
          destination        = "all-services"
          destination_type   = "SERVICE_CIDR_BLOCK"
          network_entity_key = "service_gateway"
        },
        {
          description        = "Remote home VCN through DRG"
          destination        = local.home_vcn_cidr
          destination_type   = "CIDR_BLOCK"
          network_entity_key = "drg"
        }
      ]
    }
  }

  home_security_lists = {
    app = {
      display_name = local.home.vcn.security_lists.app.name
      ingress_rules = [
        {
          description = "Allow home VCN SSH"
          protocol    = "6"
          source      = local.home_vcn_cidr
          tcp_options = {
            min = 22
            max = 22
          }
        },
        {
          description = "Allow peer VCN SSH"
          protocol    = "6"
          source      = local.peer_vcn_cidr
          tcp_options = {
            min = 22
            max = 22
          }
        }
      ]
      egress_rules = [
        {
          description = "Allow all outbound"
          protocol    = "all"
          destination = "0.0.0.0/0"
        }
      ]
    }
  }

  peer_security_lists = {
    app = {
      display_name = local.peer.vcn.security_lists.app.name
      ingress_rules = [
        {
          description = "Allow peer VCN SSH"
          protocol    = "6"
          source      = local.peer_vcn_cidr
          tcp_options = {
            min = 22
            max = 22
          }
        },
        {
          description = "Allow home VCN SSH"
          protocol    = "6"
          source      = local.home_vcn_cidr
          tcp_options = {
            min = 22
            max = 22
          }
        }
      ]
      egress_rules = [
        {
          description = "Allow all outbound"
          protocol    = "all"
          destination = "0.0.0.0/0"
        }
      ]
    }
  }

  home_drg_route_tables = {
    from-vcn = {
      display_name = local.home.drg.route_tables.from_vcn.name
      route_rules = [
        {
          destination                            = local.peer_vcn_cidr
          destination_type                       = "CIDR_BLOCK"
          next_hop_rpc_attachment_management_key = "peer"
        }
      ]
    }
    from-rpc = {
      display_name = local.home.drg.route_tables.from_rpc.name
      route_rules = [
        {
          destination             = local.home_vcn_cidr
          destination_type        = "CIDR_BLOCK"
          next_hop_attachment_key = "app"
        }
      ]
    }
  }

  peer_drg_route_tables = {
    from-vcn = {
      display_name = local.peer.drg.route_tables.from_vcn.name
      route_rules = [
        {
          destination                            = local.home_vcn_cidr
          destination_type                       = "CIDR_BLOCK"
          next_hop_rpc_attachment_management_key = "peer"
        }
      ]
    }
    from-rpc = {
      display_name = local.peer.drg.route_tables.from_rpc.name
      route_rules = [
        {
          destination             = local.peer_vcn_cidr
          destination_type        = "CIDR_BLOCK"
          next_hop_attachment_key = "app"
        }
      ]
    }
  }
}
