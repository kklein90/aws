resource "aws_security_group" "svc_sg" {
  name        = "TEMPLATE_SVC_NAME-${var.env}"
  description = "TEMPLATE_SVC_NAME svc sg"
  vpc_id      = data.aws_vpc.vpc1.id

  ingress {
    description = "inbound 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "TEMPLATE_SVC_NAME-${var.env}"
    owner     = "engineering"
    managment = "terraform"
    account   = var.account
    env       = var.env
    region    = var.region
    service   = "TEMPLATE_SVC_NAME"
  }
}
