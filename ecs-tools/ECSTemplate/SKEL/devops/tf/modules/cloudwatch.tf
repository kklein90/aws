resource "aws_cloudwatch_log_group" "portal_web_cw_log_group" {
  name              = "/TEMPLATE_SVC_NAME/${var.env}"
  retention_in_days = "180"

  tags = {
    owner     = "engineering"
    managment = "terraform"
    account   = var.account
    env       = var.env
    service   = "TEMPLATE_SVC_NAME"
  }
}
