
provider "github" {
  //token        = GITHUB_TOKEN environment variable
  organization = "ministryofjustice"
}

// # reference to the target repo we're creating a github hook on
data "github_repository" "hmpps_base_packer" {
  full_name = "ministryofjustice/hmpps-base-packer"
}
