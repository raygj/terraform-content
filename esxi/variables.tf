variable "guest_name" {
  description = "full name of VM"
}

variable "disk_store" {
  description = "SSD or SATA"
  default     = "SSD"
}

variable "memsize" {
  description = "amount of RAM in GB"
}

variable "guest_number" {
  description = "used in notes field, should match guest name"
}

variable "os" {
  description = "centos7 or ubuntu, used to pick template"
  default     = "ubuntu"
}

variable "private_key" {
  description = "path to SSH key that Terraform remote-exec should use"
  default     = "~/.ssh/id_rsa"
}

variable "admin_password" {
  description = "password for ESXi root user"
}

variable "host" {
  description = "ESXi host address"
  default     = "192.168.1.228"
}
