locals {
  tags             = merge(var.tags, { module-name = "app" }, { env = var.env })
  name_prefix      = "${var.env}-${var.component}"
  parameters       = concat(var.parameters, [var.component])
  policy_resources = concat([for i in local.parameters : "arn:aws:ssm:us-east-1:060795929502:parameter/${i}.${var.env}.*"
  ], [var.kms_key_id])
}
