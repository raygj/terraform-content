variable "aws_region" {
  description = "AWS region"
  default     = "us-east-2"
}

variable "ami_id" {
  description = "ID of the AMI to provision. Default is Ubuntu 18.04 LTS" // https://cloud-images.ubuntu.com/locator/ec2
  default     = "ami-0600ae90df54755e1"
}

variable "count" {
  description = "How many servers to provision"
  default     = 1
}

variable "instance_type" {
  description = "type of EC2 instance to provision."
  default     = "t2.micro"
}

variable "name" {
  description = "name to pass to Name tag"
  default     = "jray-ptfe-jenkins-ec2"
}

variable "owner" {
  description = "jray@hashicorp.com"
}

variable "key_name" {
  description = "jray"
}

variable "ttl" {
  description = "A desired time to live (not enforced via terraform)"
  default     = "-1"
}

variable "user_data" {
  description = "A user data script"
  default     = "cd /tmp && echo \"Provisioned by Terraform\" > user_data.txt"
}

variable security_group_id {
  default = "subnet-055c621fd6b3df116,subnet-05f16307416fe2c02"
}

variable "sg_ids" {
  type    = "list"
  default = ["sg-08dc78d1f405f6f4d"]
}

variable "vpc_id" {
  description = "existing VPC to deploy resources into"
  default     = "vpc-0a8898bdcbdde208f"
}
