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
