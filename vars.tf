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
variable "app_subnets" {
  description = "List of subnet IDs where the Auto Scaling group instances will be launched."
}


# Listener rule.
variable "private_listener_arn" {
  description = "ARN of the private load balancer listener to associate with this rule."
}

variable "lb_priority" {
  description = "Priority for the listener rule, determining its evaluation order. Lower values are evaluated first."
}

# Route 53 Record.
variable "zone_id" {
  description = "The ID of the Route53 hosted zone where the record will be created."
}

variable "private_alb_dns_name" {
  description = "DNS name of the private Application Load Balancer (ALB) to which the Route53 record will point."
}

variable "public_alb_dns_name" {
  description = "DNS name of the public ALB for routing traffic to frontend components."
}

# Public Target Group Variables
variable "default_vpc_id" {
  description = "The VPC ID where the public target group is created, usually for hosting publicly accessible resources."
}

# Target attachment with Public ALB TG.
variable "private_alb_ip_address" {
  description = "Provide the A record DNS name for the Private ALB"
}

# Public ALB listener rule.
variable "public_listener_arn" {
  description = "Provide the Public ALB Listener ARN"
}

# IAM Role
variable "parameters" {
  description = "Pass the SSM required parameter for roles"
}

# Monitoring
variable "prometheus_server_cidr" {
  description = "Provide the prometheus server CIDR"
}

variable "kms_key_id" {
  description = "Provide the KMS KEY ARN"
}