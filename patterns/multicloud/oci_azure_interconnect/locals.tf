locals {
  config       = yamldecode(file(var.payload_file))
  landing_zone = local.config.landing_zone
  azure        = local.config.azure
  oci          = local.config.oci
  interconnect = local.config.interconnect

  tags = merge(
    try(local.landing_zone.default_tags, {}),
    {
      owner = try(local.landing_zone.owner, "foggykitchen")
    }
  )

  azure_location            = local.azure.location
  azure_resource_group_name = local.azure.resource_group.name
  oci_compartment_ocid      = local.oci.compartment_ocid
  oci_tenancy_ocid          = local.oci.tenancy_ocid

  azure_vnet = {
    name          = local.azure.networking.vnet.name
    address_space = local.azure.networking.vnet.address_space
    subnets = {
      gateway = {
        name = local.azure.networking.vnet.subnets.gateway.name
        cidr = local.azure.networking.vnet.subnets.gateway.cidr
      }
      private = {
        name = local.azure.networking.vnet.subnets.private.name
        cidr = local.azure.networking.vnet.subnets.private.cidr
      }
    }
  }

  oci_vcn = {
    name        = local.oci.networking.vcn.name
    dns_label   = try(local.oci.networking.vcn.dns_label, null)
    cidr_blocks = local.oci.networking.vcn.cidr_blocks
    subnets = {
      private = {
        name                       = local.oci.networking.vcn.subnets.private.name
        cidr_block                 = local.oci.networking.vcn.subnets.private.cidr
        dns_label                  = try(local.oci.networking.vcn.subnets.private.dns_label, null)
        prohibit_public_ip_on_vnic = true
        prohibit_internet_ingress  = true
      }
    }
  }

  azure_private_rules = [
    {
      name                       = "allow-ssh-from-oci"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = local.oci_vcn.cidr_blocks[0]
      destination_address_prefix = "*"
      description                = "Allow SSH from OCI private CIDR over interconnect."
    },
    {
      name                       = "allow-http-from-oci"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = local.oci_vcn.cidr_blocks[0]
      destination_address_prefix = "*"
      description                = "Allow application traffic from OCI private CIDR over interconnect."
    }
  ]

  oci_security_lists = {
    private = {
      display_name = "sl-${local.oci_vcn.name}-private"
      ingress_rules = [
        {
          description = "Allow SSH from Azure private CIDR."
          protocol    = "6"
          source      = local.azure_vnet.subnets.private.cidr
          source_type = "CIDR_BLOCK"
          tcp_options = {
            min = 22
            max = 22
          }
        },
        {
          description = "Allow HTTP from Azure private CIDR."
          protocol    = "6"
          source      = local.azure_vnet.subnets.private.cidr
          source_type = "CIDR_BLOCK"
          tcp_options = {
            min = 80
            max = 80
          }
        }
      ]
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
}
