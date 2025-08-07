terraform {
  backend "s3" {
    bucket = "ytensor42-common"
    key = "terraform-state/ecs/tfstate"
    region = "us-west-2"
  }
}

provider "aws" {
  region = "us-west-2"
}

variable "vpc_name" {
  type = string
  default = "default"
}

variable "app_name" {
  type = string
  default = "webapp"
}

variable "image_tag" {
  type = string
  default = "1.0.arm"
}

module "vpc" {
  source = "git@github.com:ytensor42/tf-modules.git//aws/data/vpc"
  vpc_name = var.vpc_name
}

module "instance" {
  source = "git@github.com:ytensor42/tf-modules.git//aws/data/ec2"
  instance_name = "default-webapp"
}

data "aws_ecr_repository" "app" {
  name = "peregrine/webapp"
}

## ECS Role, Policies
resource "aws_iam_role" "exec_role" {
  name = "${var.app_name}-ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Effect = "Allow",
      Sid    = ""
    }]
  })
}

resource "aws_iam_role_policy_attachment" "exec_attach" {
  role       = aws_iam_role.exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

## Security Groups
module "sg_alb" {
  source = "git@github.com:ytensor42/tf-modules.git//aws/sg"
  sg_name = "${var.vpc_name}-sg-ecs-alb"
  vpc_id = module.vpc.vpc_id
  ingresses = [{
    from = 80
    to = 80
    protocol = "TCP"
    cidr = ["0.0.0.0/0"]
    sg = []
  }]
  description = "ALB security group for ${var.app_name} application"
}

module "sg_task" {
  source = "git@github.com:ytensor42/tf-modules.git//aws/sg"
  sg_name = "${var.vpc_name}-sg-ecs-task"
  vpc_id = module.vpc.vpc_id
  ingresses = [{
    from = 5000
    to = 5000
    protocol = "TCP"
    cidr = []
    sg = [module.sg_alb.id]
  }]
  description = "Target security group for ${var.app_name} application"
}

## ECS fargate
module "vpce" {
  source = "git@github.com:ytensor42/tf-modules.git//aws/vpce/interface" 
  vpc_name = var.vpc_name
  network_type = "private"
  endpoint = "ecr"
}

module "ecs_fargate" {
  source = "./fargate"
  vpc_id = module.vpc.vpc_id
  vpc_name = var.vpc_name
  app_name = var.app_name
  db_host = module.instance.private_dns_name
  ecr_repo_url = "${data.aws_ecr_repository.app.repository_url}:${var.image_tag}"
  cpu_architecture = "ARM64"
  execution_role_arn = aws_iam_role.exec_role.arn
  public_subnet_ids = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  task_sg_ids = [module.sg_task.id]
  alb_sg_ids = [module.sg_alb.id]
}
