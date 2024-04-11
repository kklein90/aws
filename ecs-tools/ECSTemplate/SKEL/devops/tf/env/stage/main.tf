terraform {
  backend "s3" {
    bucket         = "asterkey-us-east-1-dev-terraform-state"
    key            = "staging/CHANGE-ME"
    region         = "us-east-1"
    profile        = "staging"
    dynamodb_table = "terraform-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "staging"
}

module "CHANGE-ME" {
  source = "../../modules"
  env                         = "TEMPLATE_TF_SHORT_ENV"
  region                      = "TEMPLATE_TF_REGION"
  account                     = "TEMPLATE_TF_ACCOUNT"
  alb1-hostname               = "TEMPLATE_TF_ALB_DNS_NAME"
  alb-name                    = "TEMPLATE_TF_ALB_NAME"
  cluster-name                = "TEMPLATE_TF_ECS_CLUSTER_NAME"
  task-role-arn               = "TEMPLATE_TF_ECS_ROLE_ARN"
  execution-role-arn          = "TEMPLATE_TF_ECS_ROLE_ARN"
  svc-discovery-dns-namespace = "TEMPLATE_TF_SVC_DISC_DNS_NAMESPACE"
