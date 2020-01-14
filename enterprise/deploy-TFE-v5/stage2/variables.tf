# gather infra values from Stage 1 state stored in TFC

data "terraform_remote_state" "vpc" {
  backend = "remote"
  config {
    organization = "jray-hashi"
    workspaces = {
      name = "tfe_deploy-stage1-demo-us-east"
    }
  }
}