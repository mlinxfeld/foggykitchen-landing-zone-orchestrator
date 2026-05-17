module "landing_zone" {
  source = "../../../../../patterns/oci/drg_hub_spoke"

  payload_file         = "${path.module}/landing-zone.yaml"
  admin_ssh_public_key = var.admin_ssh_public_key
}
