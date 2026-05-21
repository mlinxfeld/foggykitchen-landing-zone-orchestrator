module "landing_zone" {
  source = "../../../../../patterns/oci/drg_cross_region"

  providers = {
    oci      = oci
    oci.peer = oci.peer
  }

  payload_file = "${path.module}/landing-zone.yaml"
}
