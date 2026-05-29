module "landing_zone" {
  source = "../../../../../patterns/oci/devops_build_only"

  payload_file = "${path.module}/landing-zone.yaml"
}
