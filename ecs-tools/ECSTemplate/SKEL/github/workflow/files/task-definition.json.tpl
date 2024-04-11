{
    "containerDefinitions": [
        {
            "name": "CONTAINERNAME",
            "image": "IMAGE",
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
            "linuxParameters": {
                "initProcessEnabled": true
            },
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
                    "awslogs-group": "LOGGROUP",
                    "awslogs-region": "REGION",
                    "awslogs-stream-prefix": "ecs"
                },
                "secretOptions": []
            }
        },
        {
            "name": "datadog-agent",
            "image": "public.ecr.aws/datadog/agent:latest",
            "environment":[
                {
                    "name": "DD_API_KEY",
                    "value": "DD-API-KEY"
                },
                {
                    "name": "ECS_FARGATE",
                    "value": "true"
                },
                {
                    "name": "DD_SITE",
                    "value": "datadoghq.com"
                }
            ]
        }
    ],
    "family": "FAMILY",
    "taskRoleArn": "ROLE",
    "executionRoleArn": "ROLE",
    "networkMode": "awsvpc",
    "volumes": [],
    "requiresAttributes": [
        {
            "name": "com.amazonaws.ecs.capability.logging-driver.awslogs"
        },
        {
            "name": "ecs.capability.execution-role-awslogs"
        },
        {
            "name": "com.amazonaws.ecs.capability.ecr-auth"
        },
        {
            "name": "com.amazonaws.ecs.capability.docker-remote-api.1.19"
        },
        {
            "name": "com.amazonaws.ecs.capability.task-iam-role"
        },
        {
            "name": "ecs.capability.execution-role-ecr-pull"
        },
        {
            "name": "com.amazonaws.ecs.capability.docker-remote-api.1.18"
        },
        {
            "name": "ecs.capability.task-eni"
        },
        {
            "name": "com.amazonaws.ecs.capability.docker-remote-api.1.29"
        }
    ],
    "placementConstraints": [],
    "requiresCompatibilities": [
        "FARGATE"
    ],
    "cpu": "1024",
    "memory": "2048",
    "runtimePlatform": {
        "cpuArchitecture": "X86_64",
        "operatingSystemFamily": "LINUX"
    },
    "tags": [
        {
            "key": "owner",
            "value": "engineering"
        },
        {
            "key": "managment",
            "value": "terraform"
        },
        {
            "key": "env",
            "value": "ENV"
        },
        {
            "key": "service",
            "value": "TEMPLATE_ECS_SVC_NAME"
        },
        {
            "key": "account",
            "value": "ACCOUNT"
        }
    ]
}
