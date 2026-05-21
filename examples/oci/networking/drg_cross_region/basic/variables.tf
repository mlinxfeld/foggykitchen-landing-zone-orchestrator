variable "user_ocid" {
  description = "OCI user OCID used by the provider."
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint of the OCI API key."
  type        = string
}

variable "private_key_path" {
  description = "Path to the OCI API private key."
  type        = string
}
