module "landing_zone" {
  source = "../../../../../patterns/azure/hub_spoke"

  payload_file         = "${path.module}/landing-zone.yaml"
  admin_ssh_public_key = ""
}
