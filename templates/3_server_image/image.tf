// Run this file with the following command
// terraform apply -var tenancy_ocid=$OCI_TENANCY -auto-approve

provider "oci" {
  alias  = "home"
  region = local.home_region
}

variable "tenancy_ocid" {}

data "oci_identity_tenancy" "account" {
    tenancy_id = var.tenancy_ocid
}
data "oci_identity_regions" "account" {}

locals {
    region_map ={
        for city in data.oci_identity_regions.account.regions :
        city.key => city.name
    }
    home_region = lookup(
        local.region_map,
        data.oci_identity_tenancy.account.home_region_key
    )
}

data "oci_core_images" "service" {
    compartment_id = var.compartment_id
    filter {
        name = "operating_system"
        values = [ "Oracle Autonomous Linux" ]
    }
}

data "oci_core_shapes" "service" {
    compartment_id = var.compartment_id
    image_id = data.oci_core_images.service.images[0].id
}

/*
resource "oci_core_instance" "test_instance" {
    #Required
    availability_domain = var.instance_availability_domain
    compartment_id = var.compartment_id
    shape = var.instance_shape
}
*/

output "shapes" {
  value = data.oci_core_shapes.service
}