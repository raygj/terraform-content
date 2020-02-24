# TFC|E Workspace and Repo Strategies

Goal: provide examples of Terraform Cloud (TFC) Terraform Enterprise (TFE) Workspace and Git Repo strategies as recommend by HashiCorp TFC documentation. This guide will walk through the most-common approach (single repo, multi-workspace).

Terraform Cloud (TFC) is the name of the platform; TFC is available in a SaaS multi-tenant solution or as TFE in a self-hosted deployment. In this guide, TFC will be used for ease, but assume that all instruction applies to TFE.

## overall strategies

- Terraform Cloud Documentation [HERE](https://www.terraform.io/docs/cloud/workspaces/repo-structure.html)
- each repository containing Terraform code should be a manageable chunk of infrastructure
- when repositories are interrelated, we recommend using remote state to transfer information between workspaces
- use `tfe_variable` resource of the [TFC provider](https://www.terraform.io/docs/providers/tfe/r/variable.html) or these [Variable Scripts](https://github.com/hashicorp/terraform-guides/tree/master/operations/variable-scripts) to set variables and minimize manual effort

### Three Approaches

- Multiple Workspaces per Repo
  - A single repo attached to multiple workspaces is the simplest best-practice approach
- Branches
  - For organizations that prefer long-running branches, we recommend creating a branch for each environment
- Directories
  - Each workspace is configured with a different Terraform Working Directory.

# Single Repo, Multiple workspaces

_use a single source repo for multiple workspaces; environments are set using variables_

# Overview

```
workspace: aws-network-prod
|- repo: aws-networking
 - vars: prod
```

```
 workspace: aws-network-stage
 |- repo: aws-networking
  - vars: stage
```

## steps

  1. create repo `aws-networking`
  2. create workspace `aws-networking-prod`
  3. set variables for prod
  4. create workspace `aws-networking-stage`
  5. set variables for stage

### step 1: create repo

- create a repo for your code, in this case `aws-networking`
- analyze the required variables for the code

### step 3: create TFC workspace
