locals {
  config       = yamldecode(file(var.payload_file))
  landing_zone = local.config.landing_zone
  cloud        = local.config.cloud
  architecture = local.config.architecture
  devops       = local.config.devops

  compartment_ocid = local.cloud.compartment_ocid
  region           = local.cloud.home_region
  defined_tags     = try(local.landing_zone.defined_tags, {})
  freeform_tags    = try(local.landing_zone.freeform_tags, {})

  project_name        = local.devops.project.name
  project_description = try(local.devops.project.description, null)

  notification_enabled = try(local.devops.project.enable_notifications, false)
  logging_enabled      = try(local.devops.project.enable_logging, false)

  github_connection_key = "github"
  github_repository_key = "app"
  ocir_artifact_key     = "app_image"
  build_pipeline_key    = "app"

  github_branch = try(local.devops.github.branch, "main")
}
