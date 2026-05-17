locals {
  config        = yamldecode(file(var.payload_file))
  landing_zone  = local.config.landing_zone
  cloud         = local.config.cloud
  architecture  = local.config.architecture
  features      = local.config.features
  networking    = local.config.networking
  peering       = local.config.peering
  routing       = local.config.routing
  security      = local.config.security
  nat_gateway   = local.config.nat_gateway
  bastion       = local.config.bastion
  private_dns   = local.config.private_dns
  compute       = local.config.compute
  load_balancer = local.config.load_balancer

  payload_dir = dirname(var.payload_file)

  tags = merge(
    local.landing_zone.default_tags,
    {
      owner = local.landing_zone.owner
    }
  )

  resource_group_name = local.cloud.resource_group.name
  location            = local.cloud.location

  hub = local.networking.hub

  spokes = {
    for spoke_key, spoke in local.networking.spokes : spoke_key => {
      name          = spoke.name
      address_space = spoke.address_space
      subnets = {
        for subnet_key, subnet in spoke.subnets : subnet_key => {
          name  = subnet.name
          cidr  = subnet.cidr
          key   = "${spoke_key}.${subnet_key}"
          is_pe = subnet_key == "private_endpoints"
        }
      }
    }
  }

  hub_subnets = {
    for subnet_key, subnet in local.hub.subnets : subnet_key => {
      name = subnet.name
      cidr = subnet.cidr
      key  = "hub.${subnet_key}"
    }
  }

  subnet_cidrs_by_ref = merge(
    { for subnet_key, subnet in local.hub_subnets : "hub.${subnet_key}" => subnet.cidr },
    merge([
      for spoke_key, spoke in local.spokes : {
        for subnet_key, subnet in spoke.subnets : "${spoke_key}.${subnet_key}" => subnet.cidr
      }
    ]...)
  )

  nat_subnet_refs = toset(try(local.nat_gateway.attach_to_subnets, []))

  compute_instances = {
    for instance_key, instance in try(local.compute.instances, {}) : instance_key => {
      name           = instance.name
      subnet_ref     = instance.subnet_ref
      size           = instance.size
      admin_username = instance.admin_username
      image = {
        publisher = instance.image.publisher
        offer     = instance.image.offer
        sku       = instance.image.sku
        version   = instance.image.version
      }
      custom_data = try(instance.cloud_init, null) != null ? filebase64("${local.payload_dir}/${instance.cloud_init}") : null
    }
  }

  load_balancer_backend_refs = toset(try(local.load_balancer.backend_vm_refs, []))

  route_tables = local.features.routing && local.routing.enabled ? {
    app_frontend = {
      location = local.location
      routes = local.routing.firewall_next_hop.enabled ? [
        {
          name           = "default-via-firewall"
          address_prefix = "0.0.0.0/0"
          next_hop_type  = "VirtualAppliance"
          next_hop_ip    = local.routing.firewall_next_hop.ip_address
        }
      ] : []
      subnet_ids = [module.spoke_vnets["app"].subnet_ids["frontend"]]
    }
    app_backend = {
      location = local.location
      routes = local.routing.firewall_next_hop.enabled ? [
        {
          name           = "default-via-firewall"
          address_prefix = "0.0.0.0/0"
          next_hop_type  = "VirtualAppliance"
          next_hop_ip    = local.routing.firewall_next_hop.ip_address
        }
      ] : []
      subnet_ids = [module.spoke_vnets["app"].subnet_ids["backend"]]
    }
    data_database = {
      location = local.location
      routes = local.routing.firewall_next_hop.enabled ? [
        {
          name           = "default-via-firewall"
          address_prefix = "0.0.0.0/0"
          next_hop_type  = "VirtualAppliance"
          next_hop_ip    = local.routing.firewall_next_hop.ip_address
        }
      ] : []
      subnet_ids = [module.spoke_vnets["data"].subnet_ids["database"]]
    }
    data_private_endpoints = {
      location   = local.location
      routes     = []
      subnet_ids = [module.spoke_vnets["data"].subnet_ids["private_endpoints"]]
    }
  } : {}

  private_dns_vnet_links = local.features.private_dns && local.private_dns.enabled ? merge(
    {
      hub = {
        vnet_id              = module.hub_vnet.vnet_id
        registration_enabled = false
      }
    },
    {
      for spoke_key, mod in module.spoke_vnets : spoke_key => {
        vnet_id              = mod.vnet_id
        registration_enabled = false
      }
    }
  ) : {}
}
