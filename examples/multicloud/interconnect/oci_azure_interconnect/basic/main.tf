module "landing_zone" {
  source = "../../../../../patterns/multicloud/oci_azure_interconnect"

  payload_file         = "${path.module}/landing-zone.yaml"
  admin_ssh_public_key = var.admin_ssh_public_key
}
