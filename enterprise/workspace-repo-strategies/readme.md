# TFC|E Workspace and Repo Strategies

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

## steps

  1. create repo `aws-networking-us-east`
  2. create workspace `aws-networking-us-east-prod`
  3. set variables for prod

  < repeat for networking-us-east-stage and then core-compute-us-east-prod and stage >

## step 1: create repo

- create a repo for your code, in this case `aws-networking-us-east`
- analyze the required variables for the code

## step 2: create TFC workspace

- set name to `aws-networking-us-east-prod`
- configure VCS repo connection to `aws-networking-us-east`

![image](/images/workspace-repo-strat-workspaces.png)

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


# Remote State

# Run Triggers

# Conclusion
