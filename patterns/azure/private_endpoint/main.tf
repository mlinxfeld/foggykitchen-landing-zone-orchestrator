module "hub_spoke" {
  source = "../hub_spoke"

  payload_file         = var.payload_file
  admin_ssh_public_key = var.admin_ssh_public_key
}

module "storage" {
  count  = local.features.private_endpoint && local.storage.enabled ? 1 : 0
  source = "git::https://github.com/mlinxfeld/terraform-az-fk-storage.git?ref=main"

  name                          = local.storage.name
  resource_group_name           = module.hub_spoke.resource_group_name
  location                      = local.location
  account_tier                  = try(local.storage.account_tier, "Standard")
  account_replication_type      = try(local.storage.account_replication_type, "LRS")
  account_kind                  = try(local.storage.account_kind, "StorageV2")
  access_tier                   = try(local.storage.access_tier, "Hot")
  https_traffic_only_enabled    = true
  min_tls_version               = "TLS1_2"
  public_network_access_enabled = try(local.storage.public_network_access_enabled, false)
  create_containers             = try(local.storage.create_containers, false)
  containers                    = try(local.storage.containers, {})
  create_file_shares            = try(local.storage.create_file_shares, false)
  file_shares                   = try(local.storage.file_shares, {})
  enable_network_rules          = try(local.storage.enable_network_rules, true)
  network_rules = {
    default_action             = try(local.storage.network_rules.default_action, "Deny")
    bypass                     = try(local.storage.network_rules.bypass, ["AzureServices"])
    ip_rules                   = try(local.storage.network_rules.ip_rules, [])
    virtual_network_subnet_ids = local.resolved_storage_subnet_ids
  }
  tags = local.tags
}

module "private_endpoints" {
  for_each = local.features.private_endpoint && local.private_endpoints.enabled ? local.resolved_private_endpoints : {}
  source   = "git::https://github.com/mlinxfeld/terraform-az-fk-private-endpoint.git?ref=main"

  name                           = each.value.name
  location                       = local.location
  resource_group_name            = module.hub_spoke.resource_group_name
  subnet_id                      = each.value.subnet_id
  private_connection_resource_id = module.storage[0].storage_account_id
  subresource_names              = each.value.subresource_names
  private_dns_zone_ids           = each.value.private_dns_zone_ids
  private_ip_address             = each.value.private_ip_address
  tags                           = local.tags
}
