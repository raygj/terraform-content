provider "aws" {
  region = "${var.aws_region}"
}

module "terraform-enterprise" {
  source  = "app.terraform.io/jray-hashi/terraform-enterprise/aws"
  version = "0.1.2"
}

vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
domain       = "example.com"
license_file = "company.rli"

output "deploy-tfe" { # need to update output name - check downstream dependencies
  value = {
    application_endpoint         = "${module.tfe-cluster.application_endpoint}"
    application_health_check     = "${module.tfe-cluster.application_health_check}"
    iam_role                     = "${module.tfe-cluster.iam_role}"
    install_id                   = "${module.tfe-cluster.install_id}"
    installer_dashboard_password = "${module.tfe-cluster.installer_dashboard_password}"
    installer_dashboard_url      = "${module.tfe-cluster.installer_dashboard_url}"
    primary_public_ip            = "${module.tfe-cluster.primary_public_ip}"
    ssh_private_key              = "${module.tfe-cluster.ssh_private_key}"
  }
}