terraform {
  backend "s3" {
    bucket = "<s3_bucket>"
    key = "<tfstate_key>"
    region = "<aws_region>"
  }
}

provider "aws" {
  region = "<aws_region>" 
}

#############################################################
variable "vpc_name" { default = "default" }
variable "app_name" { default = "python-webapp1" }
variable "image_tag" { default = "2.0.arm" }
variable "python_webapp1_secret_name" { default = "secret-test-string" }
variable "public_zone_name" { default = "aws.ansolute.com" }
variable "container_port" { default = 5000 }
variable "certificate_arn" { default = "arn:aws:acm:us-west-2:119145547444:certificate/6d98ee01-144c-40d2-bef9-011762206153" }

module "vpc" {
  source = "<module_base>/aws/data/vpc"
  vpc_name = var.vpc_name
}

data "aws_ecr_repository" "app" {
  name = "ansolute/web-python"
}

data "aws_secretsmanager_secret" "secret" {
  name = var.python_webapp1_secret_name
}

data "aws_secretsmanager_secret_version" "secret" {
  secret_id = data.aws_secretsmanager_secret.secret.id
}

locals {
  secret = jsondecode(data.aws_secretsmanager_secret_version.secret.secret_string)
  container = [{
    name  = var.app_name
    image = "${data.aws_ecr_repository.app.repository_url}:${var.image_tag}"
    portMappings = [{
      containerPort = var.container_port
      hostPort      = var.container_port
      protocol      = "tcp"
    }]
    environment = [
      {
        name = "DB_HOST"
        value = local.secret["DB_HOST"]
      },
      {
        name = "DB_PORT"
        value = local.secret["DB_PORT"]
      },
      {
        name = "DB_NAME"
        value = local.secret["DB_NAME"]
      },
      {
        name = "DB_USER"
        value = local.secret["DB_NAME"]
      },
      {
        name = "DB_PASSWORD"
        value = local.secret["DB_PASSWORD"]
      },
    ]
  }]
}

## Security Groups
resource "aws_security_group" "sg_alb" {
  name        = "${var.vpc_name}-sg-ecs-alb"
  description = "ALB security group for ${var.app_name} application"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
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
    Name = "${var.vpc_name}-sg-ecs-alb"
  }
}

resource "aws_security_group" "sg_service" {
  name        = "${var.vpc_name}-sg-ecs-service"
  description = "Service security group for ${var.app_name} application"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = []
    sg = [aws_security_group.sg_alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-sg-ecs-service"
  }
}

## ECS fargate
module "ecs" {
  source = "<module_base>/aws/ecs"
  vpc_id = module.vpc.vpc_id
  app_name = var.app_name
  public_zone_name = var.public_zone_name
  cpu_architecture = "ARM64"
  container = local.container
  container_port = var.container_port
  certificate_arn = var.certificate_arn
  public_subnet_ids = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  service_sg_ids = [aws_security_group.sg_service.id]
  alb_sg_ids = [aws_security_group.sg_alb.id]
}

# outputs

output "container" {
  value = local.secret
}

output "alb_dns_name" {
  value = module.ecs.alb_dns_name
}

output "service_url" {
  value = module.ecs.service_url
}
