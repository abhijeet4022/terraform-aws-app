resource "aws_autoscaling_group" "main" {
  name                      = "${local.name_prefix}-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = var.app_subnets


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


