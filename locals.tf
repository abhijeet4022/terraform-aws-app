locals {
  tags        = merge(var.tags, { module-name = "app" }, { env = var.env })
  name_prefix = "${var.env}-${var.component}"
}