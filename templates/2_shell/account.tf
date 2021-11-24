// Run this file with the following command
// terraform apply -var tenancy_ocid=$OCI_TENANCY -auto-approve

variable "tenancy_ocid" {}

data "oci_identity_tenancy" "account" {
    tenancy_id = var.tenancy_ocid
}

output "account" {
  value = data.oci_identity_tenancy.account
}