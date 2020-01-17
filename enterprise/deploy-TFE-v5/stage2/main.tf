provider "aws" {
  region = "us-east-2"
}

module "tfe-cluster" {
  source  = "app.terraform.io/jray-hashi/terraform-enterprise/aws"
  version = "0.1.3"

  domain       = "var.domain_name"
  license_file = "var.license_file_path"
  vpc_id       = "var.vpc_id"

}

output "tfe-cluster" {
  value = {
    application_endpoint         = "${module.tfe-cluster.application_endpoint}"
    application_health_check     = "${module.tfe-cluster.application_health_check}"
    iam_role                     = "${module.tfe-cluster.iam_role}"
    install_id                   = "${module.tfe-cluster.install_id}"
    installer_dashboard_password = "${module.tfe-cluster.installer_dashboard_password}"
    installer_dashboard_url      = "${module.tfe-cluster.installer_dashboard_url}"
    primary_public_ip            = "${module.tfe-cluster.primary_public_ip}"
    ssh_private_key              = "${module.tfe-cluster.ssh_private_key}"
    ssh_config_file              = "${module.tfe-cluster.ssh_config_file}"
  }
}

