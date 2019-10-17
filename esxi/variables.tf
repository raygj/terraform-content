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
  description = "centos or ubuntu, used to pick template"
  default     = "ubuntu"
}
