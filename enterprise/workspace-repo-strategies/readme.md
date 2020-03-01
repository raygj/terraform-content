# TFC|E Workspace and Repo Strategies

## Goals

Provide examples of Terraform Cloud (TFC) Terraform Enterprise (TFE) Workspace and Git Repo strategies as recommend by HashiCorp TFC documentation.

1. this guide will walk through the most-common approach (single repo, multi-workspace),
2. demonstrate how to use [Cross-Workspace State Access](https://www.terraform.io/docs/cloud/workspaces/state.html#cross-workspace-state-access) to access resources in another workspace, and
3. demo how to use [Run Triggers](https://www.terraform.io/docs/cloud/workspaces/run-triggers.html) to create an infrastructure pipeline.

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
workspace: aws-networking-us-east-prod
|- repo: aws-networking-us-east
variables: aws-networking-us-east-prod
|- repo: aws-networking-us-east-prod-set-vars
```

```
 workspace: aws-networking-us-east-stage
 |- repo: aws-networking-us-east
 variables: aws-networking-us-east-stage
 |- repo: aws-networking-us-east-stage-set-vars
```

```
 workspace: aws-core-compute-us-east-prod
 |- repo: aws-core-compute-us-east
 variables: aws-core-compute-us-east-prod
 |- repo: aws-core-compute-us-east-prod-set-vars
```

```
 workspace: aws-core-compute-us-east-stage
 |- repo: aws-core-compute-us-east
 variables: aws-core-compute-us-east-stage
 |- repo: aws-core-compute-us-east-stage-set-vars
```

### complete workspace view

![image](/images/workspace-repo-strat-workspaces.png)

## steps

  1. create repo `aws-networking-us-east`
  2. create workspace `aws-networking-us-east-prod`
  3. set variables for prod

## step 1: create repo

- create a repo for your code, in this case `aws-networking-us-east`
- analyze the required variables for the code

## step 2: create TFC workspace

- set name to `aws-networking-prod`
- configure VCS repo connection to `aws-networking-us-east`

![image](/images/workspace-repo-strat-workspaces.png)

## step 3: set variables for prod

- there are a number of options on how to set variables in TFC;

1. you could set them manually in the UI,
2. use an API call [such as](https://github.com/hashicorp/terraform-guides/tree/master/operations/variable-scripts),
3. use TF CLI and the Terraform Enterprise provider,
4. use workspaces in TFC itself along with the Terraform Enterprise provider to create a reliable source for each environment (i.e, prod, stage, dev) with dedicated repos or long-running  branches within a single repo.

- for this walkthrough, dedicated workspaces will be used to support the Terraform Provider code for each environment (prod and stage); both are stored in this [repo](https://github.com/raygj/terraform-content/tree/master/enterprise/workspace-repo-strategies)

code is [HERE](https://github.com/raygj/terraform-content/blob/master/enterprise/workspace-repo-strategies/single-repo-multi-workpace/set_tfc_vars.tf)

### main.tf snippet

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

### variables.tf snippet

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
