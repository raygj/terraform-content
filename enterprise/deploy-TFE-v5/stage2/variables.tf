#variable "aws_region" {
#  description = "define target AWS region"
#  default     = "us-east-2"
#}

variable "domain_name" {
  description = "FQDN of TFE instance"
  default     = "jray-tfe.hashidemos.io"
}

variable "license_file_path" {
  description = "local path to TFE license file"
  default     = "/Users/jray/hashi/terraform/tfe-lic"
}

variable "vpc_id" {
  description = "VPC ID of an existing VPC or the one built in Stage 1"
  default     = ""
}