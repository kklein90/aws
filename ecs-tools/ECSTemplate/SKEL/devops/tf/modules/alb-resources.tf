resource "aws_lb_target_group" "alb_target_grp" {
  name        = "tg-TEMPLATE_SVC_NAME-${var.env}"
  port        = "8080"
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.vpc1.id

  tags = {
    owner     = "engineering"
    managment = "terraform"
    account   = var.account
    env       = var.env
    service   = "TEMPLATE_SVC_NAME"
  }
}

data "aws_lb" "external_lb1" {
  name = var.alb-name
}

data "aws_lb_listener" "listener" {
  load_balancer_arn = data.aws_lb.external_lb1.arn
  port              = 443
}

resource "aws_lb_listener_rule" "listener_rule" {
  listener_arn = data.aws_lb_listener.listener.arn
  priority     = 2
  tags = {
    Name = var.env == "production" ? "TEMPLATE_SVC_HOST_NAME.TEMPLATE_SVC_DOMAIN" : "${var.account}-TEMPLATE_SVC_HOST_NAME.TEMPLATE_SVC_DOMAIN"
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_grp.arn
  }

  condition {
    host_header {
      values = [var.env == "production" ? "TEMPLATE_SVC_HOST_NAME.TEMPLATE_SVC_DOMAIN" : "${var.account}-TEMPLATE_SVC_HOST_NAME.TEMPLATE_SVC_DOMAIN"]
    }
  }
}
