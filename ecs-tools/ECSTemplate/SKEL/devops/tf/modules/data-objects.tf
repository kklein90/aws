variable "vpc-name" {
  type = map(string)
  default = {
    develop    = "development"
    staging    = "stagging"
    production = "production"
  }
}

data "aws_vpc" "vpc1" {
  filter {
    name   = "tag:Name"
    values = ["asterkey-${lookup(var.vpc-name, "${var.env}")}"]
  }
}
