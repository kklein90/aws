resource "aws_ssm_parameter" "dev_runtime_env" {
  count       = var.account == "develop" ? 1 : 0
  name        = "/TEMPLATE_SVC_NAME-runtime-env-develop"
  description = "portal website runtime env"
  type        = "SecureString"
  value       = "0"

  tags = {
    owner      = "engineering"
    management = "terraform"
    account    = var.account
    env        = var.env
    service    = "TEMPLATE_SVC_NAME"
    region     = var.region
  }

  lifecycle {
    ignore_changes = [value]
  }

}

resource "aws_ssm_parameter" "stage_runtime_env" {
  count       = var.account == "develop" ? 1 : 0
  name        = "/TEMPLATE_SVC_NAME-runtime-env-staging"
  description = "portal website runtime env"
  type        = "SecureString"
  value       = "0"

  tags = {
    owner      = "engineering"
    management = "terraform"
    account    = var.account
    env        = var.env
    service    = "TEMPLATE_SVC_NAME"
    region     = var.region
  }

  lifecycle {
    ignore_changes = [value]
  }

}

resource "aws_ssm_parameter" "prod_runtime_env" {
  count       = var.account == "develop" ? 1 : 0
  name        = "/TEMPLATE_SVC_NAME-runtime-env-production"
  description = "portal website runtime env"
  type        = "SecureString"
  value       = "0"

  tags = {
    owner      = "engineering"
    management = "terraform"
    account    = var.account
    env        = var.env
    service    = "TEMPLATE_SVC_NAME"
    region     = var.region
  }

  lifecycle {
    ignore_changes = [value]
  }

}
