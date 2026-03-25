# Read the output state from Part 1 (Docker / terraform directory) so that data
# can be shared between the two Terraform directories as required by the README.
# The local backend path resolves to terraform/terraform.tfstate after `terraform apply`
# has been run inside the terraform/ directory.
data "terraform_remote_state" "docker" {
  backend = "local"
  config = {
    path = "${path.root}/../terraform/terraform.tfstate"
  }
}
