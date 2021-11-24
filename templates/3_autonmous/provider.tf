// Run this file with the following command
// terraform apply -var tenancy_ocid=$OCI_TENANCY -auto-approve

provider "oci" {}

data "oci_core_images" "service" {
    compartment_id = var.compartment_id
}

