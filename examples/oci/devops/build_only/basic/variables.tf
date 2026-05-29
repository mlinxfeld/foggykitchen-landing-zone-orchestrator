variable "tenancy_ocid" {
  description = "OCI tenancy OCID."
  type        = string
}

variable "user_ocid" {
  description = "OCI user OCID."
  type        = string
}

variable "fingerprint" {
  description = "OCI API signing key fingerprint."
  type        = string
}

variable "private_key_path" {
  description = "Path to the OCI API private key."
  type        = string
}

variable "region" {
  description = "OCI region for the build-only pattern example."
  type        = string
}

variable "compartment_ocid" {
  description = "OCI compartment OCID for the build-only pattern example."
  type        = string
}

variable "github_pat_secret_ocid" {
  description = "OCI Vault secret OCID containing the GitHub personal access token."
  type        = string
}

variable "availability_domain" {
  description = "Optional passthrough variable kept only to stay compatible with shared tfvars files."
  type        = string
  default     = null
}
