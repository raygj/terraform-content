# TFE v5 Clustered Deployment on AWS using TFC

The goal of this walkthrough is step through the process of deploying TFE v5 clustered architecture from a workspace running on TFC SaaS. Why? TFC offers security (Sentinel policy, secure variables) and collaboration (PMR, notifications) tooling to support this type of automated installation and it will be convenient to deploy a TFE instance at will on AWS from a workspace.

**NOTE** when referring to published guides or docs, these will be labeled as "official" versus docs that were created by HashiCorp field SEs that may not be officially supported by HashiCorp Support.

## Official Pre-Install Checklist

https://www.terraform.io/docs/enterprise/before-installing/index.html

1. Choose a deployment method: **clustered, AKA v5** versus individual v4
2. Choose an operational mode: **production, external services** versus demo mode, etc.
3. Credentials Required: **TFE license file + TLS cert for TFE to use**
4. Data Storage: data storage service **S3**
5. Linux Instance: **Linux machine image** (for clustering v5) or versus a running Linux instance (if deploying individual v4)

## Deploying a TFE Cluster

https://www.terraform.io/docs/enterprise/install/cluster-aws.html

1. Follow the pre-install checklist.
2. Prepare the machine that will run Terraform.
3. Prepare some required AWS infrastructure.
4. Write a Terraform configuration that calls the deployment module.
5. Apply the configuration to deploy the cluster.

## Prepare TFC

### Publish the TFE Module in the PMR

- fork the HashiCorp Official Module to your private GitHub account

https://github.com/hashicorp/terraform-aws-terraform-enterprise

- publish the module in your PMR

#### Create

### Terraform Module

#### Prerequisites: Stage 1

These resources (and a valid license file) are required, but not included in the sample TF code:

* VPC
* Subnets (both public and private) spread across multiple AZs
* A DNS Zone
* A Certificate available in ACM for the hostname provided (or a wildcard certificate for the domain)
* A license file provided by your Technical Account Manager

Use Roger Berlind's TFE v4 Stage 1 code from [THIS REPO](https://github.com/rberlind/private-terraform-enterprise/tree/automated-aws-pes-installation)

1. On your local computer, navigate to a directory such as `GitHub/tfe` into which you want to clone this repository.
2. Run `git clone https://github.com/hashicorp/private-terraform-enterprise.git` to clone the repository.
3. Run `cd private-terraform-enterprise` to navigate into the cloned repository.
4. Run `git checkout automated-aws-pes-installation` (to switch to the automated-aws-pes-installation branch).


Use the Terraform code in either the examples/aws/network-public or the examples/aws/network-private directory to create the VPC, subnets, other network resources, security group, KMS key, and PTFE source bucket, then follow these steps. Otherwise, create the equivalent resources using some other method and then skip to Stage 2.

1. Run `cd examples/aws/network-public` or `cd examples/aws/network-private`to navigate to one of the network directories that contains the Stage 1 Terraform code.
1. Run `cp network.auto.tfvars.example network.auto.tfvars` to create your own tfvars file.
1. Edit network.auto.tfvars, set namespace to "<name>-ptfe" where "<name>" is some suitable prefix for your PTFE deployment, set `bucket_name` to the name of the PTFE source bucket you wish to create, set `cidr_block` to a valid CIDR block, and set `subnet_count` to the number of subnets you want in your VPC. When creating a public network, all of the subnets will be public. When creating a private network, that number of private subnets will be created along with two public subnets to allow outbound internet access and for use with the ALB. If creating a private network, also set `ssh_key_name` to the name of your SSH key pair so it can be used with the bastion host created in the private network. Finally, save the file.
1. Run `AWS_ACCESS_KEY_ID=<your_aws_key>`.
1. Run `export AWS_SECRET_ACCESS_KEY=<your_aws_secret_key>`.
1. Run `export AWS_DEFAULT_REGION=us-east-1` or pick some other region.  But if you select a different region, make sure you select AMIs from that region.
1. Run `terraform init` to initialize the Stage 1 Terraform configuration and download providers.
1. Run `terraform apply` to provision the Stage 1 resources. Type "yes" when prompted. The apply takes about 1 minute.
1. Note the `kms_id`, `security_group_id`, `subnet_ids`, and `vpc_id` outputs which you will need in Stage 2. (When creating a private network, you will have `private_subnet_ids` and `public_subnet_ids` outputs instead of the `subnet_ids` output.)
1. Run `cd ..` to go back to the examples/aws directory.
1. Add your PTFE license file to your PTFE source bucket that was created. You can do this in the AWS Console







#### main.tf

provider "aws" {
  region = "us-east-2"
}

module "terraform-enterprise" {
  source  = "app.terraform.io/jray-hashi/terraform-enterprise/aws"
  version = "0.1.2"
}

  vpc_id       = "vpc-123456789abcd1234"
  domain       = "example.com"
  license_file = "company.rli"
}

output "tfe-beta" {
  value = {
    application_endpoint         = module.tfe-cluster.application_endpoint
    application_health_check     = module.tfe-cluster.application_health_check
    iam_role                     = module.tfe-cluster.iam_role
    install_id                   = module.tfe-cluster.install_id
    installer_dashboard_password = module.tfe-cluster.installer_dashboard_password
    installer_dashboard_url      = module.tfe-cluster.installer_dashboard_url
    primary_public_ip            = module.tfe-cluster.primary_public_ip
    ssh_private_key              = module.tfe-cluster.ssh_private_key
  }
}