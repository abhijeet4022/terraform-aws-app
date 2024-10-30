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
  name        = "${local.name_prefix}-tg"
  port        = var.app_port
  target_type = "instance"
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  tags        = var.tags
}

# Create the Listener rule. Route the traffic to respective TG based on hostname
resource "aws_lb_listener_rule" "main" {
  listener_arn = var.private_listener_arn
  priority     = var.lb_priority
  tags         = { Name = "${var.component}-rule" }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  condition {
    host_header {
      values = [
        var.component == "frontend" ? "${var.env}.learntechnology.cloud" : "${var.component}-${var.env}.learntechnology.cloud"
      ]
    }
  }
}

# Create Route53 record for every component (tg) towards ALB DNS.
resource "aws_route53_record" "main" {
  zone_id = var.zone_id
  name    = var.component == "frontend" ? var.env : "${var.component}-${var.env}"
  type    = "CNAME"
  ttl     = 30
  records = [var.component == "frontend" ? var.public_alb_dns_name : var.private_alb_dns_name]
}

# Target Group Create for Public LB to accept the traffic from user.
resource "aws_lb_target_group" "public" {
  count       = var.component == "frontend" ? 1 : 0 # This will run only for frontend component.
  name        = "${local.name_prefix}-public-tg"
  port        = var.app_port
  target_type = "ip"
  protocol    = "HTTP"
  vpc_id      = var.default_vpc_id # This TG is part of Public LB.
  tags        = var.tags
  #  health_check {
  #    enabled             = true
  #    healthy_threshold   = 2
  #    interval            = 5
  #    path                = "/"
  #    port                = var.app_port
  #    timeout             = 2
  #    unhealthy_threshold = 2
  #    matcher             = "400"
  #  }
}

# Attach the Private LB with above TG.
resource "aws_lb_target_group_attachment" "test" {
  count             = var.component == "frontend" ? length(var.private_alb_ip_address) : 0 # Only for Public LB
  target_group_arn  = aws_lb_target_group.public[0].arn
  target_id         = element(var.private_alb_ip_address, count.index )
  port              = 80
  availability_zone = "all"
}
