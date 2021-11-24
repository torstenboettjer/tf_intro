// Run this file with the following command
// terraform apply -var tenancy_ocid=$OCI_TENANCY -auto-approve

data "oci_core_images" "service" {
    compartment_id = var.compartment_id
    filter {
        name = "operating_system"
        values = [ "Oracle Autonomous Linux" ]
    }
}

output "images" {
  value = data.oci_core_images.service.images
}