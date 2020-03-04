formatting# TFC|E Workspace and Repo Strategies

## Goals

Provide examples of Terraform Cloud (TFC) Terraform Enterprise (TFE) Workspace and Git Repo strategies as recommend by HashiCorp TFC documentation.

1. this guide will walk through the most-common approach (single repo, multi-workspace),
2. demonstrate how to use [Cross-Workspace State Access](https://www.terraform.io/docs/cloud/workspaces/state.html#cross-workspace-state-access) to access resources in another workspace, and
3. demonstrate how to use [Run Triggers](https://www.terraform.io/docs/cloud/workspaces/run-triggers.html) to create an infrastructure pipeline.

**Reminder** Terraform Cloud (TFC) is the name of the platform; TFC is available in a SaaS multi-tenant solution or as TFE in a self-hosted deployment. In this guide, TFC will be used for ease, but assume that all instruction applies to TFE if you are running a self-hosted environment.

## overall strategies

- Terraform Cloud Documentation [HERE](https://www.terraform.io/docs/cloud/workspaces/repo-structure.html)
- each repository containing Terraform code should be a manageable chunk of infrastructure
- when repositories are interrelated, we recommend using remote state to transfer information between workspaces
- use `tfe_variable` resource of the [TFC provider](https://www.terraform.io/docs/providers/tfe/r/variable.html) or these [Variable Scripts](https://github.com/hashicorp/terraform-guides/tree/master/operations/variable-scripts) to set variables and minimize manual effort

### Workspace-Rep Organization: Three Approaches

- Multiple Workspaces per Repo
  - A single repo attached to multiple workspaces is the simplest, most-used approach
- Branches
  - For organizations that prefer long-running branches, we recommend creating a branch for each environment
- Directories
  - Each workspace is configured with a different Terraform Working Directory.

# Single Repo, Multiple workspaces

_use a single source repo for multiple workspaces; environments are set using variables_

## overview

_this an example workspace and variable mapping strategy_

```
infra workspace: aws-networking-us-east-prod
|- repo: aws-networking-us-east
variable workspace: aws-networking-us-east-prod-set-vars
|- repo: /aws-networking-us-east/aws-networking-us-east-prod-set-vars
```

```
 infra workspace: aws-networking-us-east-stage
 |- repo: aws-networking-us-east
 variable workspace: aws-networking-us-east-stage
 |- repo: /aws-networking-us-east/aws-networking-us-east-stage-set-vars
```

```
 infra workspace:  aws-core-compute-us-east-prod
 |- repo: aws-core-compute-us-east
 variable workspace: aws-core-compute-us-east-prod
 |- repo: /aws-core-compute-us-east/aws-core-compute-us-east-prod-set-vars
```

```
 infra workspace: aws-core-compute-us-east-stage
 |- repo: aws-core-compute-us-east
 variable workspace: aws-core-compute-us-east-stage
 |- repo: /aws-core-compute-us-east/aws-core-compute-us-east-stage-set-vars
```

# Steps

  1. create repo `aws-networking-us-east`
  2. create workspace `aws-networking-us-east-prod`
  3. set variables for prod

  < repeat for _networking-us-east-stage_ and then _core-compute-us-east-prod|stage_ >

## step 1: create repo

- create a repo for your code (or clone the example code) in this case `aws-networking-us-east`
- analyze the required variables for the code

## step 2: create the TFC infra workspace

- set name to `aws-networking-us-east-prod`
- configure VCS repo connection to `aws-networking-us-east`

## step 3: set variables for prod

- there are a number of options on how to set variables in TFC;

1. you could set them manually in the UI,
2. use an API call [such as this example](https://github.com/hashicorp/terraform-guides/tree/master/operations/variable-scripts),
3. use TF CLI and the Terraform Enterprise provider,
4. use `*auto.tfvars` file to have TFC automatically pull variables in, note, the values will never be visible in the workspace variables UI
5. use workspaces in TFC itself along with the Terraform Enterprise provider to create a reliable source for each environment (i.e, prod, stage, dev) with dedicated repos or long-running  branches within a single repo.

- for this walkthrough option 5 will be used; dedicated workspaces will be created to host the Terraform Provider code that will set the variables for each environment's workspace (prod and stage)
- the TF code for each environment will reside in a sub-directory within the resource's repo
- for example:

```

/aws-networking-us-east/aws-networking-us-east-prod-set-vars
                       /aws-networking-us-east-stage-set-vars

```
- when you provision the workspace, set the Terraform Working Directory to the correct path
- for example

![image](/images/workspace-repo-strat-var-ws-settings.png)

### TFE provider main.tf snippet

```
Configure the Terraform Enterprise Provider
provider "tfe" {
 hostname = "var.tfc_hostname
 token    = var.tfc_token
}

resource "tfc_organization" "acme-corp" {
 name  = var.tfc_org_name
 email = var.email
}

resource "tfc_workspace" "aws-networking-us-east" {
 name         = var.workspace_name
 organization = tfc_organization.acme-corp.id
}
# sample terraform variable //look into storing on Consul kv
resource "tfc_variable" "aws-networking-us-east" {
workspace_id = "${tfc_workspace.aws-networking-us-east.id}"
description  = "a useful description"
 key          = var.key1
 value        = var.value1
 category     = terraform
 sensitive    = false
}
```

### TFE provider variables.tf snippet

```
variable "key1" {
  description = "target organization name"
  default = ""
}

variable "value1" {
  description = "target organization name"
  default = ""
}
```

#### Sample Variable Workspace Variable Set

![image](/images/workspace-repo-strat-var-ws-variables.png)

## Complete Workspace Layout

if you follow the outlined approach you will ned up with this workspace structure:

![image](/images/workspace-repo-strat-workspaces.png)

# Remote State

remote_state is a Terraform data source. review the [documentation](https://www.terraform.io/docs/providers/terraform/d/remote_state.html) for details.

in this walkthrough, the network and core infra workspaces are separated to avoid operational complexity (multi-speed changes, separation of duties, application of policy guardrails), `remote_state` is used to access data from one workspace (core compute) to another (networking).

keep in mind that only outputs from the root module are supported, so you will need to thread the module output into the root module if you would like to access outputs from a nested module.

## Pull Network Values

the process is to pull the values for the EC2 configuration of `aws-networking-us-east-prod` from the `aws-networking-us-east-prod` state residing in the workspace of the same name.

- these data references reside in the `core compute` along side the EC2 code
- define the data source, then reference it within the resource block as a `data` value
- TF 0.12 formatting

```
data "terraform_remote_state" "subnet_id" {
  backend = "remote"

  config = {
    organization = "jray-hashi"
    workspaces = {
      name = "aws-networking-us-east-prod"
    }
  }
}

data "terraform_remote_state" "vpc_security_group_ids" {
  backend = "remote"

  config = {
    organization = "jray-hashi"
    workspaces = {
      name = "aws-networking-us-east-prod"
    }
  }
}

data "terraform_remote_state" "public_ip" {
  backend = "remote"

  config = {
    organization = "jray-hashi"
    workspaces = {
      name = "aws-networking-us-east-prod"
    }
  }
}

# ...
  subnet_id                   = data.terraform_remote_state.subnet_id.outputs.subnet_id
  vpc_security_group_ids      = [data.terraform_remote_state.vpc_security_group_ids.outputs.id]

#...
connection {
  host        = "${data.terraform_remote_state.public_ip}"

```

# Run Triggers

# Conclusion


_________________________
Next Steps 03.01

Differentiate prod and stage by more than just the CDIR block. VPC needs to be named differently? Or is the IP address enough to make it unique in the same region?

Make sure all code is 0.12 compliant, FMT and VALIDATE

Finish EC2 remote_state code
	* need to add “data” definition to variable code of network main.tf
	* need to make sure data sources map to variable code

Assumption is that any remote_state call from within TF code running in TFC will authenticate using “self”
	* need to verify and add explanation to README
