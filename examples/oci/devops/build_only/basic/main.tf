module "landing_zone" {
  source = "../../../../../patterns/oci/devops_build_only"

  payload_file = "${path.module}/landing-zone.yaml"
  payload_template_vars = {
    tenancy_ocid           = var.tenancy_ocid
    compartment_ocid       = var.compartment_ocid
    region                 = var.region
    github_pat_secret_ocid = var.github_pat_secret_ocid
  }
}
