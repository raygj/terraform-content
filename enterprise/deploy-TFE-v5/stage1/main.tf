provider "aws" {
  region = var.aws_region
}

resource "random_pet" "prefix" {
  count     = var.prefix != "" ? 0 : 1
  prefix    = "tfe"
  length    = 1
  separator = "-"
}

module "new_vpc" {
  source  = "app.terraform.io/jray-hashi/vpc/aws"
  version = "2.21.0"

  name                = "${local.prefix}-vpc"
  cidr                = var.cidr_block
  azs                 = var.availability_zones
  private_subnets     = var.private_subnet_cidr_blocks
  public_subnets      = var.public_subnet_cidr_blocks
  default_vpc_tags    = local.tags
  private_subnet_tags = local.tags
  public_subnet_tags  = local.tags
  enable_nat_gateway  = true
}

resource "aws_route53_zone" "new" {
  count = var.domain_name == "" ? 0 : 1
  name  = var.domain_name
  tags  = local.tags
}

