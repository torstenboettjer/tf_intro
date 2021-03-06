// Run this file with the following command
// terraform apply -var tenancy_ocid=$OCI_TENANCY -auto-approve

provider "oci" {
  alias  = "home"
  region = local.home_region
}

variable "tenancy_ocid" {}

data "oci_identity_tenancy" "sevensteps" {
    tenancy_id = var.tenancy_ocid
}
data "oci_identity_regions" "sevensteps" {}

data "oci_identity_compartments" "sevensteps" {
    compartment_id = var.tenancy_ocid
    compartment_id_in_subtree = true
    name = "organization_project_dev_network_compartment"
}

data "oci_identity_availability_domains" "sevensteps" {
    compartment_id = var.tenancy_ocid
}

data "oci_core_subnets" "sevensteps" {
    compartment_id = data.oci_identity_compartments.sevensteps.compartments[0].id
    filter {
      name = "display_name" 
      values = ["organization_project_dev_app"]
    }
}

locals {
    region_map ={
        for city in data.oci_identity_regions.sevensteps.regions :
        city.key => city.name
    }
    home_region = lookup(
        local.region_map,
        data.oci_identity_tenancy.sevensteps.home_region_key
    )
}

data "oci_core_images" "autonomous" {
    compartment_id = var.tenancy_ocid
    filter {
        name = "operating_system"
        values = [ "Oracle Autonomous Linux" ]
    }
}

data "oci_core_shapes" "intel" {
    compartment_id = data.oci_identity_compartments.sevensteps.compartments[0].id
    image_id = data.oci_core_images.autonomous.images[0].id
    availability_domain = data.oci_identity_availability_domains.sevensteps.availability_domains[0].name
    filter {
        name = "name"
        values = [ "VM.Standard2.1", "VM.Standard2.4" ]
    }
}

resource "oci_core_instance" "autonomous_linux" {
    availability_domain = data.oci_identity_availability_domains.sevensteps.id
    compartment_id = var.tenancy_ocid
    shape = data.oci_core_shapes.intel.shapes[0].name
    display_name = var.display_name
    source_details {
        source_id = data.oci_core_images.autonomous.images[0].id
        source_type = "image"
    }
    create_vnic_details {
        assign_public_ip = false
        subnet_id = data.oci_core_subnets.sevensteps.subnets[0].id
    }
}

output "cloud_server" {
  value = oci_core_instance.autonomous_linux
}