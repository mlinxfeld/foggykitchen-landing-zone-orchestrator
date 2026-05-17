module "landing_zone" {
  source = "../../../../../patterns/oci/lpg_local_peering"

  payload_file         = "${path.module}/landing-zone.yaml"
  admin_ssh_public_key = var.admin_ssh_public_key
}
