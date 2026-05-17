resource "azurerm_resource_group" "this" {
  name     = local.azure_resource_group_name
  location = local.azure_location
  tags     = local.tags
}

module "azure_vnet" {
  source = "git::https://github.com/mlinxfeld/terraform-az-fk-vnet.git?ref=main"

  name                = local.azure_vnet.name
  location            = local.azure_location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = local.azure_vnet.address_space

  subnets = {
    for subnet_key, subnet in local.azure_vnet.subnets : subnet_key => {
      address_prefixes                              = [subnet.cidr]
      private_endpoint_network_policies             = "Enabled"
      private_link_service_network_policies_enabled = true
      service_endpoints                             = []
      delegations                                   = []
    }
  }

  tags = local.tags
}

module "azure_private_nsg" {
  source = "git::https://github.com/mlinxfeld/terraform-az-fk-nsg.git?ref=main"

  name                = "nsg-${local.azure_vnet.name}-private"
  location            = local.azure_location
  resource_group_name = azurerm_resource_group.this.name
  rules               = local.azure_private_rules
  subnet_associations = {
    private = {
      subnet_id = module.azure_vnet.subnet_ids["private"]
    }
  }
  tags = local.tags
}

module "azure_compute" {
  source = "git::https://github.com/mlinxfeld/terraform-az-fk-compute.git?ref=v0.3.5"

  name                = local.azure.compute.instance.name
  location            = local.azure_location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = module.azure_vnet.subnet_ids["private"]
  vm_size             = local.azure.compute.instance.size
  admin_username      = local.azure.compute.instance.admin_username
  ssh_public_key      = var.admin_ssh_public_key
  image_reference = {
    publisher = local.azure.compute.instance.image.publisher
    offer     = local.azure.compute.instance.image.offer
    sku       = local.azure.compute.instance.image.sku
    version   = local.azure.compute.instance.image.version
  }
  identity_type = "SystemAssigned"
  tags          = merge(local.tags, { cloud = "azure" })
}

resource "azurerm_public_ip" "interconnect" {
  name                = local.interconnect.azure.public_ip_name
  location            = local.azure_location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_virtual_network_gateway" "interconnect" {
  name                = local.interconnect.azure.virtual_network_gateway.name
  location            = local.azure_location
  resource_group_name = azurerm_resource_group.this.name

  type     = "ExpressRoute"
  vpn_type = "PolicyBased"
  sku      = local.interconnect.azure.virtual_network_gateway.sku

  ip_configuration {
    name                 = "interconnect-vng-ipconf"
    public_ip_address_id = azurerm_public_ip.interconnect.id
    subnet_id            = module.azure_vnet.subnet_ids["gateway"]
  }

  lifecycle {
    ignore_changes = [
      ip_configuration[0].public_ip_address_id
    ]
  }

  tags = local.tags
}

resource "azurerm_express_route_circuit" "interconnect" {
  name                  = local.interconnect.azure.express_route_circuit.name
  location              = local.azure_location
  resource_group_name   = azurerm_resource_group.this.name
  service_provider_name = "Oracle Cloud FastConnect"
  peering_location      = local.interconnect.azure.express_route_circuit.peering_location
  bandwidth_in_mbps     = local.interconnect.azure.express_route_circuit.bandwidth_in_mbps

  sku {
    tier   = "Standard"
    family = "MeteredData"
  }

  allow_classic_operations = false

  tags = local.tags
}

module "oci_vcn" {
  source = "git::https://github.com/mlinxfeld/terraform-oci-fk-vcn.git?ref=main"

  compartment_ocid = local.oci_compartment_ocid
  name             = local.oci_vcn.name
  dns_label        = local.oci_vcn.dns_label
  vcn_cidr_blocks  = local.oci_vcn.cidr_blocks
  security_lists   = local.oci_security_lists
  subnets = {
    private = {
      cidr_block                    = local.oci_vcn.subnets.private.cidr_block
      display_name                  = local.oci_vcn.subnets.private.name
      dns_label                     = local.oci_vcn.subnets.private.dns_label
      security_list_keys            = ["private"]
      include_default_security_list = false
      prohibit_internet_ingress     = local.oci_vcn.subnets.private.prohibit_internet_ingress
      prohibit_public_ip_on_vnic    = local.oci_vcn.subnets.private.prohibit_public_ip_on_vnic
      defined_tags                  = {}
      freeform_tags                 = local.tags
    }
  }
  freeform_tags = local.tags
}

resource "oci_core_drg" "interconnect" {
  compartment_id = local.oci_compartment_ocid
  display_name   = local.interconnect.oci.drg.name
  freeform_tags  = local.tags
}

resource "oci_core_drg_route_distribution" "import" {
  drg_id            = oci_core_drg.interconnect.id
  distribution_type = "IMPORT"
  display_name      = "${local.interconnect.oci.drg.name}-import"
}

resource "oci_core_drg_route_distribution_statement" "import_fastconnect" {
  drg_route_distribution_id = oci_core_drg_route_distribution.import.id
  action                    = "ACCEPT"

  match_criteria {
    match_type      = "DRG_ATTACHMENT_TYPE"
    attachment_type = "VIRTUAL_CIRCUIT"
  }

  priority = 10
}

resource "oci_core_drg_attachment" "vcn" {
  drg_id       = oci_core_drg.interconnect.id
  vcn_id       = module.oci_vcn.vcn_id
  display_name = "${local.interconnect.oci.drg.name}-vcn-attachment"
}

resource "oci_core_drg_route_table" "interconnect" {
  drg_id                           = oci_core_drg.interconnect.id
  display_name                     = "${local.interconnect.oci.drg.name}-rt"
  import_drg_route_distribution_id = oci_core_drg_route_distribution.import.id
}

resource "oci_core_drg_route_table_route_rule" "to_vcn" {
  drg_route_table_id         = oci_core_drg_route_table.interconnect.id
  destination                = local.oci_vcn.cidr_blocks[0]
  destination_type           = "CIDR_BLOCK"
  next_hop_drg_attachment_id = oci_core_drg_attachment.vcn.id
}

data "oci_core_fast_connect_provider_services" "providers" {
  compartment_id = local.oci_compartment_ocid
}

locals {
  microsoft_azure_fastconnect_provider_service_id = data.oci_core_fast_connect_provider_services.providers.fast_connect_provider_services[
    index(data.oci_core_fast_connect_provider_services.providers.fast_connect_provider_services.*.provider_name, "Microsoft Azure")
  ].id
}

resource "oci_core_virtual_circuit" "interconnect" {
  display_name         = local.interconnect.oci.virtual_circuit.name
  compartment_id       = local.oci_compartment_ocid
  gateway_id           = oci_core_drg.interconnect.id
  type                 = "PRIVATE"
  bandwidth_shape_name = local.interconnect.oci.virtual_circuit.bandwidth_shape_name

  provider_service_id       = local.microsoft_azure_fastconnect_provider_service_id
  provider_service_key_name = azurerm_express_route_circuit.interconnect.service_key

  dynamic "cross_connect_mappings" {
    for_each = local.interconnect.oci.virtual_circuit.cross_connect_mappings
    content {
      oracle_bgp_peering_ip   = cross_connect_mappings.value.oracle_bgp_peering_ip
      customer_bgp_peering_ip = cross_connect_mappings.value.customer_bgp_peering_ip
    }
  }

  depends_on = [
    azurerm_express_route_circuit.interconnect
  ]
}

resource "oci_core_drg_attachment_management" "fastconnect" {
  compartment_id     = local.oci_compartment_ocid
  attachment_type    = "VIRTUAL_CIRCUIT"
  display_name       = "${local.interconnect.oci.drg.name}-fastconnect-attachment-management"
  network_id         = oci_core_virtual_circuit.interconnect.id
  drg_id             = oci_core_drg.interconnect.id
  drg_route_table_id = oci_core_drg_route_table.interconnect.id
}

resource "oci_core_default_route_table" "oci_default" {
  manage_default_resource_id = module.oci_vcn.default_route_table_id
  compartment_id             = local.oci_compartment_ocid
  display_name               = "default-rt-${local.oci_vcn.name}"

  route_rules {
    description       = "Route Azure private CIDR via DRG."
    destination       = local.azure_vnet.address_space[0]
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_drg.interconnect.id
  }
}

resource "azurerm_virtual_network_gateway_connection" "interconnect" {
  count = try(local.interconnect.azure.connection.enabled, false) ? 1 : 0

  name                = local.interconnect.azure.connection.name
  location            = local.azure_location
  resource_group_name = azurerm_resource_group.this.name

  type                         = "ExpressRoute"
  virtual_network_gateway_id   = azurerm_virtual_network_gateway.interconnect.id
  express_route_circuit_id     = azurerm_express_route_circuit.interconnect.id
  express_route_gateway_bypass = false

  depends_on = [
    oci_core_virtual_circuit.interconnect,
    oci_core_drg_attachment_management.fastconnect
  ]
}

module "oci_compute" {
  source = "git::https://github.com/mlinxfeld/terraform-oci-fk-compute.git?ref=main"

  name             = local.oci.compute.instance.name
  compartment_ocid = local.oci_compartment_ocid
  tenancy_ocid     = local.oci_tenancy_ocid
  deployment_mode  = "instance"
  shape            = local.oci.compute.instance.shape
  shape_config = {
    ocpus         = local.oci.compute.instance.ocpus
    memory_in_gbs = local.oci.compute.instance.memory_in_gbs
  }
  subnet_id                = module.oci_vcn.subnet_ids["private"]
  assign_public_ip         = false
  ssh_authorized_keys      = [var.admin_ssh_public_key]
  operating_system         = local.oci.compute.instance.operating_system
  operating_system_version = local.oci.compute.instance.operating_system_version
  freeform_tags            = merge(local.tags, { cloud = "oci" })
}
