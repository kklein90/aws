data "aws_route53_zone" "svc_zone" {
  provider     = aws.prod
  name         = "TEMPLATE_SVC_DOMAIN"
  private_zone = false
}

resource "aws_route53_record" "svc_cname" {
  provider = aws.prod
  zone_id  = data.aws_route53_zone.svc_zone.zone_id
  name     = var.account == "production" ? "TEMPLATE_SVC_HOST_NAME.TEMPLATE_SVC_DOMAIN" : "${var.account}-TEMPLATE_SVC_HOST_NAME.TEMPLATE_SVC_DOMAIN"
  type     = "CNAME"
  ttl      = 300
  records  = [var.alb1-hostname]

}
