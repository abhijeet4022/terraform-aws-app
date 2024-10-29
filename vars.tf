variable "tags" {}
variable "env" {}
variable "vpc_id" {
  description = "ID of the VPC where the security group will be created."
}

variable "app_port" {
  description = "Port number for the application service."
}

variable "app_subnets_cidr" {
  description = "CIDR blocks of subnets from which the application will be accessible."
}

variable "ssh_subnets_cidr" {
  description = "CIDR blocks of subnets for SSH access from the jumphost."
}

variable "component" {
  description = "Name of the application component being deployed."
}