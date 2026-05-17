locals {
  payload = yamldecode(file("${path.module}/landing-zone.yaml"))
}

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0"
    }
    oci = {
      source  = "oracle/oci"
      version = ">= 6.0.0"
    }
  }
}

provider "azurerm" {
  features {}
  use_cli = true
}

provider "oci" {
  tenancy_ocid     = local.payload.oci.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = local.payload.oci.region
}
