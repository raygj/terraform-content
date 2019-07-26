# Workspace Creation and Setup

Quick instructions for remotely executing Terraform code in Terraform Enterprise. This is the "CLI-driven run workflow" and relies on a local installation of Terraform OSS binary and a specific Terraform file (backend.tf) that tells Terraform OSS to use a remote server to execute code.

Official Documentation sources:

[workspace creation](https://www.terraform.io/docs/enterprise/workspaces/creating.html)

[the CLI-driven run workflow](https://www.terraform.io/docs/enterprise/run/cli.html)

## Step 1: Create a Workspace

1. login into [Terraform Enterprise Trial](https://app.terraform.io)
1. click on + New Workspace button
1. provide workspace name, for _source_ choose "Upload via API"
1. click on "Create Workspace"

_generally speaking you will create a workspace per app component/VM/service and one for each environment_

## Step 2: Modify Workspace Settings

1. after creating the workspace you are returned to a screen "waiting for configuration"
1. click on the "Settings" menu item, select "General"
1. if your Terraform code requires a specific version select it in the _Terraform Version_ drop-down
1. click on "Save Settings"

_unless you have specifically migrated code to Terraform 0.12.x format, you will want to select 0.11.14 from the list_

## Step 3: Modify Workspace Variables

there are two types of variables that mirror a local Terraform setup:

Terraform Variables are values you are going to supply to your Terraform Code

Environment Variables are values that would normally be set at the OS where Terraform is running

1. under _Environment Variables_ add the following variables:

`CONFIRM_DESTROY 1`

_you should check the box for "sensitive" on the Azure creds to encrypt the values and obfuscate them in the UI_

```
ARM_SUBSCRIPTION_ID
ARM_CLIENT_ID
ARM_CLIENT_SECRET
ARM_TENANT_ID
``` 

## Step 4: Create Token

1. from the main Terraform Enterprise menu, select Settings > Teams
1. select the `api-access-token` team
1. click "Create an authentication token"
1. copy the token to a secure location, you will need it in the next step

## Step 5: Local Windows Laptop Setup

[CLI config](https://www.terraform.io/docs/commands/cli-config.html#location)

1. create `terraform.rc` file and placed it in the relevant user's `%APPDATA%` directory
1. the physical location of this directory depends on your Windows version and system configuration; use `$env:APPDATA` in PowerShell to find its location on your system
1. drop this config stanza into the `terraform.rc` file, replacing the token value with the token you created in the last step

```
credentials "app.terraform.io" {
  token = "x.atlasv1.z"
}
```

## Step 6: Create a Backend Config File

1. copy an existing directory that contains Terraform code
1. create a new file called `backend.tf`
1. drop this config stanza into the file, replacing the name value for the workspace name you created in step 1

```
terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "tps"

    workspaces {
      name = "< workspce name from step 1>"
    }
  }
}
```

## Execute Code

From the directory that contains your Terraform code and backend.tf file, issue a `terraform init` and then normal `terraform plan/apply/destroy` commands. You can jump to the Terraform Enterprise UI and locate the workspace you are executing code against to see the run status. The run status will also update locally in the CLI.