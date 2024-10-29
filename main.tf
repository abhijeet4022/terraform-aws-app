# SG for APP ASG.
resource "aws_security_group" "main" {
  name        = "${local.name_prefix}-app-sg"
  description = "${local.name_prefix}-app-sg"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${local.name_prefix}-app-sg" })
}


# Ingress rule for APP ASG.
resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  for_each          = toset(var.app_subnets_cidr) # Convert list to a set to iterate over each CIDR
  description       = "Allow inbound TCP on APP port ${var.app_port} from App Subnets"
  security_group_id = aws_security_group.main.id
  cidr_ipv4         = each.value # Each CIDR block as a separate rule
  from_port         = var.app_port
  to_port           = var.app_port
  ip_protocol       = "tcp"
  tags              = { Name = "App-to-App" }
}

# Ingress rule for SSH to APP Server.
resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  for_each          = toset(var.ssh_subnets_cidr) # Convert list to a set to iterate over each CIDR
  description       = "Allow inbound TCP on SSH port ${var.app_port} from Jumphost"
  security_group_id = aws_security_group.main.id
  cidr_ipv4         = each.value # Each CIDR block as a separate rule
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  tags              = { Name = "Jumphost-to-App" }
}


# Egress rule for APP ASG.
resource "aws_vpc_security_group_egress_rule" "main" {
  security_group_id = aws_security_group.main.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


# Create Launch Template for ASG
resource "aws_launch_template" "main" {
  name                   = "${local.name_prefix}-lt"
  image_id               = var.image_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.main.id]
  user_data              = base64encode(templatefile("${path.module}/userdata.sh",
    {
      component = var.component
    }))


  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = "${local.name_prefix}-ec2" })
  }
}
