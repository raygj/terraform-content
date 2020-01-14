# TFE v5 Clustered Deployment on AWS using TFC

The goal of this walkthrough is step through the process of deploying TFE v5 clustered architecture from a workspace running on TFC SaaS. Why? TFC offers security (Sentinel policy, secure variables) and collaboration (PMR, notifications) tooling to support this type of automated installation and it will be convenient to deploy a TFE instance at will on AWS from a workspace.

**NOTE** when referring to published guides or docs, these will be labeled as "official" versus docs that were created by HashiCorp field SEs that may not be officially supported by HashiCorp Support.

## References

### Official Pre-Install Checklist

https://www.terraform.io/docs/enterprise/before-installing/index.html

1. Choose a deployment method: **clustered, AKA v5** versus individual v4
2. Choose an operational mode: **production, external services** versus demo mode, etc.
3. Credentials Required: **TFE license file + TLS cert for TFE to use**
4. Data Storage: data storage service **S3**
5. Linux Instance: **Linux machine image** (for clustering v5) or versus a running Linux instance (if deploying individual v4)

### Deploying a TFE Cluster

https://www.terraform.io/docs/enterprise/install/cluster-aws.html

1. Follow the pre-install checklist.
2. Prepare the machine that will run Terraform.
3. Prepare some required AWS infrastructure.
4. Write a Terraform configuration that calls the deployment module.
5. Apply the configuration to deploy the cluster.

### Roger Berlind's TFE v4 Code

https://github.com/rberlind/private-terraform-enterprise/tree/automated-aws-pes-installation

source for Stage 1 TF code used for prerequisite configuration, forked, and upgraded to TF 0.12

## Prepare TFC

### Publish the TFE Module in your PMR

- fork the HashiCorp Official Module to your private GitHub account

https://github.com/hashicorp/terraform-aws-terraform-enterprise

- publish the module in your PMR

## Deploy TFE

Two stages will be used to deploy TFE because there are dependencies that must be fed into the official module and separating into two steps allows the TFE instance to be deployed into existing infrastructure and/or repaved with ease.

### Prerequisites: Stage 1

- these resources (and a valid license file) are required as input

* VPC
* Subnets (both public and private) spread across multiple AZs
* A DNS Zone
* A Certificate available in ACM for the hostname provided (or a wildcard certificate for the domain)
* A license file provided by your Technical Account Manager

- using Roger Berlind's code for a "public network" deployment forked into this repo to create the VPC, subnets, other network resources, security group, KMS key, and TFE source bucket (where TFE license file will reside)

1. create a TFC workspace called `tfe_deploy-stage1-demo-us-east`

- update VCS connection settings to the location of this forked repo, for example, my workspace is mounted at the repo path `https://github.com/raygj/terraform-content` and the working directory of the workspace is `/enterprise/deploy-TFE-v5/stage1`

![screenshot](/images/tfe-v5-deploy-stage1-workspace2.png)

**notes**

- make sure your AMI value in Stage 2 matches an available AMI in your default region
- WIP, TF CLI (OSS) code to configure the workspace in TFC started [HERE](https://github.com/raygj/terraform-content/tree/master/enterprise/tfe-provider-workspace-code)

2. using `...deploy-TFE-v5/stage1/network.tfvars` as a reference, configure Terraform Variables for the workspace as follows:

- set `namespace` to "<name>-tfe-v5" where "<name>" is some suitable prefix for your TFE deployment
- set `bucket_name` to the name of the TFE source bucket you wish to create
- set `cidr_block` to a valid CIDR block
- set `subnet_count` to the number of subnets you want in your VPC

3. set secure variables for `AWS_ACCESS_KEY_ID=<your_aws_key>` and `AWS_SECRET_ACCESS_KEY=<your_aws_secret_key>`

- example:

![screenshot](/images/tfe-v5-terraform-vars2.png)


4. run `queue plan` to initialize the Stage 1 Terraform configuration and download providers.
5. troubleshoot any TF errors, if successful you will receive feedback from TF `Plan: 11 to add, 0 to change, 0 to destory.`
6. hit `confirm & apply` to provision the Stage 1 resources.
7. note the `kms_id`, `security_group_id`, `subnet_ids`, and `vpc_id` outputs which you will need in Stage 2.
8. add your PTFE license file to your PTFE source bucket that was created. You can do this in the AWS Console.

**note** all of subnets will be public unless you modify the CIDR blocks for the security group configuration of `resource "aws_security_group"` in the `...deploy-TFE-v5/stage1/main.tf` config

### Terraform Code: Stage 2

- goal is to use remote state to access Stage 1 workspace to collect the VPC ID and other resources as needed

https://www.terraform.io/docs/providers/terraform/index.html

https://www.terraform.io/docs/cloud/run/index.html#cross-workspace-state-access

example

```

# Shared infrastructure state stored in Atlas
data "terraform_remote_state" "vpc" {
  backend = "remote"

  config {
    organization = "hashicorp"
    workspaces = {
      name = "vpc-prod"
    }
  }
}

# Terraform >= 0.12
resource "aws_instance" "foo" {
  # ...
  subnet_id = data.terraform_remote_state.vpc.outputs.subnet_id
}

```

#### main.tf

**WIP note** need to make sure all this code is TF 0.12 compliant


```

provider "aws" {
  region = "${var.aws_region}"
}

module "terraform-enterprise" {
  source  = "app.terraform.io/jray-hashi/terraform-enterprise/aws"
  version = "0.1.2"
}

vpc_id       = "data.terraform_remote_state.vpc.outputs.vpc_id"
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

# gather infra values from Stage 1 state stored in TFC

data "terraform_remote_state" "vpc" {
  backend = "remote"

  config {
    organization = "${var.org-name}"
    workspaces = {
      name = "${var.tfe-deploy-workspace-name}"
    }
  }
}

# Terraform >= 0.12
resource "aws_vpc" "need to figure this value out as it is not known until after run" {
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id # getting error on this line
}


```

