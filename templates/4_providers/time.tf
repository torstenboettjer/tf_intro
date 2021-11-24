// Run this file with the following command
// terraform apply -var tenancy_ocid=$OCI_TENANCY -auto-approve

provider "oci" {
  alias  = "home"
  region = local.home_region
}

provider "time" { }

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
    availability_domain = var.availability_domain
    filter {
        name = "name"
        values = [ "VM.Standard2.1", "VM.Standard2.4" ]
    }
}

resource "oci_core_instance" "autonomous_linux" {
    depends_on = [
      time_sleep.wait
    ]
    availability_domain = var.availability_domain
    compartment_id = var.compartment_id
    shape = data.oci_core_shapes.service.shapes[0].name
    source_details {
        source_id = data.oci_core_images.service.images[0].id
        source_type = "image"
    }
    create_vnic_details {
        assign_public_ip = false
        subnet_id = var.subnet_id
    }
}

resource "null_resource" "previous" {}

resource "time_sleep" "wait" {
  depends_on      = [null_resource.previous]
  create_duration = "1m"
}

output "server" {
  value = oci_core_instance.autonomous_linux
}