data "aws_ecs_cluster" "esc_cluster_01" {
  cluster_name = var.cluster-name
}

data "aws_subnets" "deployment_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc1.id]
  }
  filter {
    name   = "tag:usage"
    values = ["TEMPLATE_TF_SUBNET_USAGE_TAG"]
  }
}

data "aws_subnet" "subnets" {
  for_each = toset(data.aws_subnets.deployment_subnets.ids)
  id       = each.value
}


resource "aws_ecs_service" "portal_website_ecs_svc" {
  name                               = "TEMPLATE_SVC_NAME-${var.account}-svc"
  cluster                            = data.aws_ecs_cluster.esc_cluster_01.arn
  task_definition                    = aws_ecs_task_definition.portal_website_task_def.arn
  desired_count                      = 1
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  deployment_maximum_percent         = "200"
  deployment_minimum_healthy_percent = "100"
  # platform_version                   = "LATEST"
  force_new_deployment   = true
  enable_execute_command = true


  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets          = [for subnet in data.aws_subnet.subnets : subnet.id]
    security_groups  = [aws_security_group.portal_website_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.portal_website_alb_target_grp.arn
    container_name   = "TEMPLATE_SVC_NAME-${var.env}"
    container_port   = 8080
  }

  tags = {
    owner     = "engineering"
    managment = "terraform"
    account   = var.account
    env       = var.env
    service   = "TEMPLATE_SVC_NAME"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [task_definition]
  }
}
