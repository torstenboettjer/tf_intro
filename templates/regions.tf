data "oci_identity_regions" "account" {}

output "regions" {
  value = data.oci_identity_regions.account
}