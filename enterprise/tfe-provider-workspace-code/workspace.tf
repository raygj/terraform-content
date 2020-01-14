provider "tfe" {
  hostname = "${var.hostname}"
  token    = "${var.token}"
}

# workspace creation

resource "tfe_workspace" "tfe-deploy" {
  name         = "${var.tfe-deploy-workspace-name}"
  organization = "${var.org-name}"
  terraform_version = "${var.terraform_ver}"
  working_directory = "{$var.working_dir}"
  vcs_repo =
    identifier = "${var.org-repo}" # must be in format org/repo
    oauth_token_id = "${var.vcs-oauth}"
}

# notification configuration

resource "tfe_organization" "tfe-deploy" {
  organization = "${var.org-name}"
  email = "${var.prefix@hashicorp.com}"
}

resource "tfe_workspace" "tfe-deploy" {
  name         = "${var.tfe-deploy-workspace-name}"
  organization = "${var.org-name}"
}

resource "tfe_notification_configuration" "tfe-deploy" {
  name                      = "tfe-slack"
  enabled                   = true
  destination_type          = "slack"
  triggers                  = ["run:created", "run:planning", "run:needs_attention", "run:applying", "run:completed", "run:errored"]
  url                       = "https://hooks.slack.com/services/${var.slack-webhook}"
  workspace_external_id     = "${tfe_workspace.test.external_id}"
}