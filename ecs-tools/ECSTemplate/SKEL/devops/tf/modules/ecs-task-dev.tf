resource "aws_ecs_task_definition" "portal_website_task_def" {
  family                   = "TEMPLATE_SVC_NAME-${var.env}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  task_role_arn            = var.task-role-arn
  execution_role_arn       = var.execution-role-arn
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  tags = {
    owner     = "engineering"
    managment = "terraform"
    account   = var.account
    env       = var.env
    service   = "TEMPLATE_SVC_NAME"
  }


  container_definitions = <<TASKDEF
[
    {
        "name": "TEMPLATE_SVC_NAME-${var.env}",
        "image": "228923425684.dkr.ecr.us-east-1.amazonaws.com/TEMPLATE_SVC_NAME:latest",
        "cpu": 0,
        "portMappings": [
            {
                "name": "8080",
                "containerPort": 8080,
                "hostPort": 8080,
                "protocol": "tcp",
                "appProtocol": "http"
            }
        ],
        "essential": true,
        "environment": [
            TEMPLATE_ENV_VAIRABLES_JSON
        ],
        "environmentFiles": [],
        "mountPoints": [],
        "volumesFrom": [],
        "ulimits": [],
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-create-group": "true",
                "awslogs-group": "/TEMPLATE_SVC_NAME/${var.env}",
                "awslogs-region": "us-east-1",
                "awslogs-stream-prefix": "ecs"
            },
            "secretOptions": []
        }
    }
]
TASKDEF

}
