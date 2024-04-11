variable "env" {}
variable "account" {}
variable "region" {
  default = "us-east-1"
}

variable "prod_id" {
  default = "380735047240"
}

variable "dev_id" {
  default = "228923425684"
}

variable "stage_id" {
  default = "464677946080"
}

variable "alb1-hostname" {}
variable "alb-name" {}
variable "cluster-name" {}
variable "task-role-arn" {}
variable "execution-role-arn" {}
variable "svc-discovery-dns-namespace" {}

