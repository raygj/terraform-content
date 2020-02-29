# Terraform 0.12 compliant
terraform {
  required_version = "< 0.12"

# Configure the Terraform Enterprise Provider
provider "tfe" {
  hostname = "var.tfc_hostname
  token    = var.tfc_token
}

resource "tfc_organization" "acme-corp" {
  name  = var.tfc_org_name
  email = var.email
}

resource "tfc_workspace" "aws-networking" {
  name         = var.workspace_name
  organization = tfc_organization.acme-corp.id
}
# sample terraform variable //look into storing on Consul kv
resource "tfc_variable" "aws-networking" {
workspace_id = "${tfc_workspace.aws-networking.id}"
description  = "a useful description"
  key          = var.key1
  value        = var.value1
  category     = terraform
  sensitive    = false
}
resource "tfc_variable" "aws-networking" {
workspace_id = "${tfc_workspace.aws-networking.id}"
description  = "a useful description"
  key          = var.key2
  value        = var.value2
  category     = terraform
  sensitive    = false
}

# sample environment variable
resource "tfc_variable" "aws-networking" {
workspace_id = "${tfc_workspace.aws-networking.id}"
description  = "a useful description"
  key          = var.env_key1
  value        = var.env_value1
  category     = env
  sensitive    = false
}
