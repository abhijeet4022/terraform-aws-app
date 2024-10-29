variable "tags" {}
variable "env" {}

# SG information
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

# Launch Template info.
# Variable for the Amazon Machine Image (AMI) ID to be used in the launch template
variable "image_id" {
  description = "AMI ID to use in the launch template."
}

# Variable for the EC2 instance type
variable "instance_type" {
  description = "The instance type for the EC2 instances (e.g., t2.micro, m5.large)."
}

# ASG Variables
variable "max_size" {
  description = "Maximum number of instances in the Auto Scaling group."
}

variable "min_size" {
  description = "Minimum number of instances in the Auto Scaling group."
}

variable "desired_capacity" {
  description = "Initial number of instances in the Auto Scaling group."
}