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

output "home_region" {
    value = local.home_region
}