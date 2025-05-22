variable "tenancy_ocid" {
  description = "The OCID of your OCI tenancy (root compartment)."
  type        = string
}

variable "user_ocid" {
  description = "The OCID of the OCI user calling the API."
  type        = string
}

variable "fingerprint" {
  description = "The fingerprint of the API signing key."
  type        = string
}

variable "private_key_path" {
  description = "The absolute or relative path to the OCI API private key file."
  type        = string
}

variable "region" {
  description = "The OCI region where resources will be created (e.g., us-ashburn-1, ap-tokyo-1)."
  type        = string
  default     = "ap-tokyo-1" # Updated to reflect your current deployment region
}

variable "compartment_ocid" {
  description = "The OCID of the compartment where resources will be created"
  type        = string
}

variable "ubuntu_image_ocid" {
  description = "Optional: The OCID of a specific Ubuntu image. If null, dynamic lookup is used for Arm instances."
  type        = string
  default     = null
}

variable "ssh_public_key" {
  description = "The public SSH key content (e.g., from ~/.ssh/id_rsa.pub) to be authorized on the instances."
  type        = string
}
