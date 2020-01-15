variable "aws_region" {
  description = "define target AWS region"
  default     = "us-east-2"
}

variable "cidr_block" {
  description = "CIDR block range to use for the network."
  default     = "10.250.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  type        = list(string)
  description = "CIDR block ranges to use for the public subnets."
  default     = ["10.250.21.0/24", "10.250.22.0/24", "10.250.23.0/24"]
}

variable "private_subnet_cidr_blocks" {
  type        = list(string)
  description = "CIDR block ranges to use for the private subnets."
  default     = ["10.250.11.0/24", "10.250.12.0/24", "10.250.13.0/24"]
}

variable "additional_tags" {
  type        = map(string)
  description = "A map of additional tags to attach to all resources created."
  default     = {}
}

variable "availability_zones" {
  type        = list(string)
  description = "List of the Availability zones to use."
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

variable "domain_name" {
  description = "The domain to create a route53 zone for. (eg. `tfe.example.com`), will not create if left empty."
  default     = "hashidemos.io"
}

variable "prefix" {
  description = "The prefix to use on all resources, will generate one if not set."
  default     = "jray-tfe"
}

variable "namespace" {
  description = "The prefix to use on all resources, will generate one if not set."
  default     = ""
}

locals {
  prefix = element(coalescelist([var.prefix], random_pet.prefix.*.id), 0)
  tags   = merge(local.default_tags, var.additional_tags)

  default_tags = {
    Application = "Terraform Enterprise"
    Environment = "demo-sandbox"
    Owner       = "jray@hashicorp.com"
    TTL         = "-1"
  }
}