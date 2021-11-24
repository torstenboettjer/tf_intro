// Run this file with the following command
// terraform apply -var tenancy_ocid=$OCI_TENANCY -auto-approve

provider "oci" {}
variable "tenancy_ocid" {}

data "oci_core_images" "service" {
    compartment_id = var.compartment_id
    filter {
        name = "display_name"
        values = ["*Linux*"]
    }
}

output "images" {
  value = data.oci_core_images.service
}
