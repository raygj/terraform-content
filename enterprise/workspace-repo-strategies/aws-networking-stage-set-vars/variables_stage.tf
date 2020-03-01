variable "tfc_hostname" {
  description = "FQDN of TFC/E host"
  default     = ""
}

variable "tfc_token" {
  description = "secret API token for a user with access to org"
  default     = "" //can be set as ENV var, in TFC it will be marked sensitive
}

variable "tfc_org_name" {
  description = "target organization name"
  default     = ""
}

variable "email" {
  description = "email address associated with token, process, or workflow"
  default     = ""
}

variable "key1" {
  description = "sets TF VAR key1 value aws_region"
  default     = ""
}

variable "value1" {
  description = "sets TF VAR value1 value us-east-1"
  default     = ""
}

variable "key2" {
  description = "sets TF VAR key1 value vpc_cidr"
  default     = ""
}

variable "value2" {
  description = "sets TF VAR value2 value 172.100.0.0/16"
  default     = ""
}

variable "env_key1" {
  description = "sets key1 of env vars"
  default     = "CONFIRM_DESTROY"
}

variable "env_value1" {
  description = "sets value1 to key1"
  default     = "1"
}
