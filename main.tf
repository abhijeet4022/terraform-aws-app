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
  user_data = base64encode(templatefile("${path.module}/userdata.sh",
    {
      component = var.component
  }))


  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = "${local.name_prefix}-ec2" })
  }
}

# Create ASG for every component and attach the ALB TG.
resource "aws_autoscaling_group" "main" {
  name                = "${local.name_prefix}-asg"
  max_size            = var.max_size
  min_size            = var.min_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = var.app_subnets
  target_group_arns   = [aws_lb_target_group.main.arn]


  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }


  tag {
    key                 = "Name"
    value               = local.name_prefix
    propagate_at_launch = true
  }
}


# Create TG for every component
resource "aws_lb_target_group" "main" {
  name     = "${local.name_prefix}-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

# Create the Listener rule. Route the traffic to respective TG based on hostname
resource "aws_lb_listener_rule" "main" {
  listener_arn = var.private_listener_arn
  priority     = var.lb_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  condition {
    host_header {
      values = ["${var.component}-${var.env}.learntechnology.cloud"]
    }
  }
}