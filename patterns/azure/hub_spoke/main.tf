resource "azurerm_resource_group" "this" {
  name     = local.resource_group_name
  location = local.location
  tags     = local.tags
}

module "hub_vnet" {
  source = "git::https://github.com/mlinxfeld/terraform-az-fk-vnet.git?ref=main"

  name                = local.hub.name
  location            = local.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = local.hub.address_space

  subnets = {
    for subnet_key, subnet in local.hub_subnets : subnet_key => {
      address_prefixes                              = [subnet.cidr]
      private_endpoint_network_policies             = "Enabled"
      private_link_service_network_policies_enabled = true
      service_endpoints                             = []
      delegations                                   = []
    }
  }

  tags = local.tags
}

module "spoke_vnets" {
  for_each = local.spokes
  source   = "git::https://github.com/mlinxfeld/terraform-az-fk-vnet.git?ref=main"

  name                = each.value.name
  location            = local.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = each.value.address_space

  subnets = {
    for subnet_key, subnet in each.value.subnets : subnet_key => {
      address_prefixes                              = [subnet.cidr]
      private_endpoint_network_policies             = subnet.is_pe ? "Disabled" : "Enabled"
      private_link_service_network_policies_enabled = true
      service_endpoints                             = []
      delegations                                   = []
    }
  }

  tags = merge(local.tags, { spoke = each.key })
}

module "hub_to_spoke_peering" {
  for_each = local.features.vnet_peering && local.peering.hub_to_spokes ? module.spoke_vnets : {}
  source   = "git::https://github.com/mlinxfeld/terraform-az-fk-vnet-peering.git?ref=main"

  resource_group_name          = azurerm_resource_group.this.name
  vnet_1_id                    = module.hub_vnet.vnet_id
  vnet_1_name                  = module.hub_vnet.vnet_name
  vnet_2_id                    = each.value.vnet_id
  vnet_2_name                  = each.value.vnet_name
  allow_virtual_network_access = true
  allow_forwarded_traffic      = local.peering.allow_forwarded_traffic
  allow_gateway_transit        = local.peering.allow_gateway_transit
  use_remote_gateways          = local.peering.use_remote_gateways
  tags                         = merge(local.tags, { peering = each.key })
}

module "routing" {
  count  = local.features.routing && local.routing.enabled ? 1 : 0
  source = "git::https://github.com/mlinxfeld/terraform-az-fk-routing.git?ref=main"

  resource_group_name = azurerm_resource_group.this.name
  route_tables        = local.route_tables
  tags                = local.tags
}

module "hub_shared_nsg" {
  count  = local.features.nsg && local.security.nsg.enabled ? 1 : 0
  source = "git::https://github.com/mlinxfeld/terraform-az-fk-nsg.git?ref=main"

  name                = "nsg-hub-shared"
  location            = local.location
  resource_group_name = azurerm_resource_group.this.name
  rules = [
    {
      name                       = "deny-internet-inbound"
      priority                   = 4000
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
      description                = "Deny direct inbound traffic from the Internet."
    }
  ]
  subnet_associations = {
    shared = {
      subnet_id = module.hub_vnet.subnet_ids["shared"]
    }
  }
  tags = local.tags
}

module "app_frontend_nsg" {
  count  = local.features.nsg && local.security.nsg.enabled ? 1 : 0
  source = "git::https://github.com/mlinxfeld/terraform-az-fk-nsg.git?ref=main"

  name                = "nsg-app-frontend"
  location            = local.location
  resource_group_name = azurerm_resource_group.this.name
  rules = [
    {
      name                       = "deny-internet-inbound"
      priority                   = 4000
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
      description                = "Deny direct inbound traffic from the Internet."
    }
  ]
  subnet_associations = {
    frontend = {
      subnet_id = module.spoke_vnets["app"].subnet_ids["frontend"]
    }
  }
  tags = local.tags
}

module "app_backend_nsg" {
  count  = local.features.nsg && local.security.nsg.enabled ? 1 : 0
  source = "git::https://github.com/mlinxfeld/terraform-az-fk-nsg.git?ref=main"

  name                = "nsg-app-backend"
  location            = local.location
  resource_group_name = azurerm_resource_group.this.name
  rules = [
    {
      name                       = "allow-http-from-azure-lb"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = tostring(local.load_balancer.listener.port)
      source_address_prefix      = "AzureLoadBalancer"
      destination_address_prefix = "*"
      description                = "Allow application traffic from the internal load balancer."
    },
    {
      name                       = "allow-ssh-from-bastion"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = local.subnet_cidrs_by_ref["hub.bastion"]
      destination_address_prefix = "*"
      description                = "Allow operator SSH only from Azure Bastion subnet."
    },
    {
      name                       = "deny-internet-inbound"
      priority                   = 4000
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
      description                = "Deny direct inbound traffic from the Internet."
    }
  ]
  subnet_associations = {
    backend = {
      subnet_id = module.spoke_vnets["app"].subnet_ids["backend"]
    }
  }
  tags = local.tags
}

module "data_database_nsg" {
  count  = local.features.nsg && local.security.nsg.enabled ? 1 : 0
  source = "git::https://github.com/mlinxfeld/terraform-az-fk-nsg.git?ref=main"

  name                = "nsg-data-database"
  location            = local.location
  resource_group_name = azurerm_resource_group.this.name
  rules = [
    {
      name                       = "allow-ssh-from-bastion"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = local.subnet_cidrs_by_ref["hub.bastion"]
      destination_address_prefix = "*"
      description                = "Allow operator SSH only from Azure Bastion subnet."
    },
    {
      name                       = "deny-internet-inbound"
      priority                   = 4000
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
      description                = "Deny direct inbound traffic from the Internet."
    }
  ]
  subnet_associations = {
    database = {
      subnet_id = module.spoke_vnets["data"].subnet_ids["database"]
    }
  }
  tags = local.tags
}

module "data_private_endpoints_nsg" {
  count  = local.features.nsg && local.security.nsg.enabled ? 1 : 0
  source = "git::https://github.com/mlinxfeld/terraform-az-fk-nsg.git?ref=main"

  name                = "nsg-data-private-endpoints"
  location            = local.location
  resource_group_name = azurerm_resource_group.this.name
  rules = [
    {
      name                       = "deny-internet-inbound"
      priority                   = 4000
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
      description                = "Deny direct inbound traffic from the Internet."
    }
  ]
  subnet_associations = {
    private_endpoints = {
      subnet_id = module.spoke_vnets["data"].subnet_ids["private_endpoints"]
    }
  }
  tags = local.tags
}

module "nat_public_ip" {
  count  = local.features.nat_gateway && local.nat_gateway.enabled ? 1 : 0
  source = "git::https://github.com/mlinxfeld/terraform-az-fk-public-ip.git?ref=main"

  name                = "pip-${local.landing_zone.name}-nat"
  location            = local.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

module "nat_gateway" {
  count  = local.features.nat_gateway && local.nat_gateway.enabled ? 1 : 0
  source = "git::https://github.com/mlinxfeld/terraform-az-fk-natgw.git?ref=main"

  name                = "natgw-${local.landing_zone.environment}"
  location            = local.location
  resource_group_name = azurerm_resource_group.this.name
  create_public_ip    = false
  public_ip_id        = module.nat_public_ip[0].id
  subnet_associations = {
    for subnet_ref in local.nat_subnet_refs : replace(subnet_ref, ".", "-") => {
      subnet_id = split(".", subnet_ref)[0] == "app" ? module.spoke_vnets["app"].subnet_ids[split(".", subnet_ref)[1]] : module.spoke_vnets["data"].subnet_ids[split(".", subnet_ref)[1]]
    }
  }
  tags = local.tags
}

module "bastion" {
  count  = local.features.bastion && local.bastion.enabled ? 1 : 0
  source = "git::https://github.com/mlinxfeld/terraform-az-fk-bastion.git?ref=main"

  name                = local.bastion.name
  location            = local.location
  resource_group_name = azurerm_resource_group.this.name
  bastion_subnet_id   = module.hub_vnet.subnet_ids["bastion"]
  sku                 = local.bastion.sku
  tunneling_enabled   = true
  ip_connect_enabled  = true
  tags                = local.tags
}

module "private_dns" {
  count  = local.features.private_dns && local.private_dns.enabled ? 1 : 0
  source = "git::https://github.com/mlinxfeld/terraform-az-fk-private-dns.git?ref=main"

  resource_group_name    = azurerm_resource_group.this.name
  private_dns_zone_names = toset(local.private_dns.zones)
  vnet_links             = local.private_dns_vnet_links
  tags                   = local.tags
}

resource "azurerm_lb" "internal" {
  count               = local.features.internal_load_balancer && local.load_balancer.enabled ? 1 : 0
  name                = local.load_balancer.name
  location            = local.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "internal-frontend"
    subnet_id                     = module.spoke_vnets["app"].subnet_ids["frontend"]
    private_ip_address_allocation = "Dynamic"
  }

  tags = local.tags
}

resource "azurerm_lb_backend_address_pool" "internal" {
  count           = local.features.internal_load_balancer && local.load_balancer.enabled ? 1 : 0
  name            = "app-backend-pool"
  loadbalancer_id = azurerm_lb.internal[0].id
}

resource "azurerm_lb_probe" "internal" {
  count           = local.features.internal_load_balancer && local.load_balancer.enabled ? 1 : 0
  name            = "app-health-probe"
  loadbalancer_id = azurerm_lb.internal[0].id
  protocol        = local.load_balancer.health_probe.protocol
  port            = local.load_balancer.health_probe.port
}

resource "azurerm_lb_rule" "internal" {
  count                          = local.features.internal_load_balancer && local.load_balancer.enabled ? 1 : 0
  name                           = "app-listener"
  loadbalancer_id                = azurerm_lb.internal[0].id
  protocol                       = local.load_balancer.listener.protocol
  frontend_port                  = local.load_balancer.listener.port
  backend_port                   = local.load_balancer.listener.port
  frontend_ip_configuration_name = "internal-frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.internal[0].id]
  probe_id                       = azurerm_lb_probe.internal[0].id
}

module "compute" {
  for_each = local.features.compute && local.compute.enabled ? local.compute_instances : {}
  source   = "git::https://github.com/mlinxfeld/terraform-az-fk-compute.git?ref=v0.3.5"

  name                = each.value.name
  location            = local.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = module.spoke_vnets[split(".", each.value.subnet_ref)[0]].subnet_ids[split(".", each.value.subnet_ref)[1]]
  vm_size             = each.value.size
  admin_username      = each.value.admin_username
  ssh_public_key      = var.admin_ssh_public_key
  identity_type       = "SystemAssigned"
  image_reference     = each.value.image
  custom_data         = each.value.custom_data
  lb_attachment = contains(local.load_balancer_backend_refs, each.key) && local.features.internal_load_balancer && local.load_balancer.enabled ? {
    backend_pool_id = azurerm_lb_backend_address_pool.internal[0].id
  } : null
  tags = merge(local.tags, { workload = each.key })
}
