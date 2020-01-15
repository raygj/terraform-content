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
  name = "${var.prefix}.${var.domain_name}"
  tags = local.tags
}

output "vpc_id" {
  value       = module.new_vpc.vpc_id
  description = "The id of the created VPC"
}

output "route53" {
  value = aws_route53_zone.new.name
}

output "subnet_tags" {
  value       = local.tags
  description = "The tags associated with the subnets created"
}

output "kms_id" {
  value = aws_kms_key.s3.key_id
}

output "bucket_name" {
  value = aws_s3_bucket.bucket.bucket
}
