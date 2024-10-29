# # Create Launch Template for ASG
# resource "aws_launch_template" "main" {
#   name                   = "${local.name_prefix}-lt"
#   image_id               = var.image_id
#   instance_type          = var.instance_type
#   vpc_security_group_ids = [aws_security_group.main.id]
#   user_data = base64encode(templatefile("${path.module}/userdata.sh",
#     {
#       component = var.component
#   }))
#
#
#   tag_specifications {
#     resource_type = "instance"
#
#     tags = merge(var.tags, { Name = "${local.name_prefix}-lt" })
#   }
#
#
# }