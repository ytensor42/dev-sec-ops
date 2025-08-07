terraform {
  backend "s3" {
    bucket = "ytensor42-common"
    key = "terraform-state/webapp/tfstate"
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

module "vpc" {
  source = "git@github.com:ytensor42/tf-modules.git//aws/data/vpc"
  vpc_name = var.vpc_name
}

data "aws_route53_zone" "zone" {
  name = "demo.ansolute.com"
  private_zone = true
}

## SSM VPC Endpoints
module "vpce" {
  source = "git@github.com:ytensor42/tf-modules.git//aws/vpce/interface" 
  vpc_name = var.vpc_name
  network_type = "private"
  endpoint = "ssm"
}

## EC2 instance
module "sg_webapp" {
  source = "git@github.com:ytensor42/tf-modules.git//aws/sg"
  sg_name = "${var.vpc_name}-sg-webapp"
  vpc_id = module.vpc.vpc_id
  ingresses = [{
    from = 5432
    to = 5432
    protocol = "TCP"
    cidr = module.vpc.private_subnet_cidrs
    sg = []
  }]
  description = "EC2 security group for application"
}

module "instance" {
  source = "git@github.com:ytensor42/tf-modules.git//aws/ec2"
  instance_name = "${var.vpc_name}-webapp"
  domain_zone = data.aws_route53_zone.zone
  ami = "ami-031da650a6471429e"
  #ami_type = "ubuntu-2204"
  instance_type = "t3.small"
  key_name = "ec2_rsa"
  iam_instance_profile = "instance-profile-ssm-ecr"
  user_data = "ubuntu-default"
  aws_subnet_id = module.vpc.private_subnet_ids[0]
  vpc_security_group_ids = [module.sg_webapp.id]
  volume_size = 30
}

output "instance" {
  value = module.instance
}


module "sg_backend_test" {
  source = "git@github.com:ytensor42/tf-modules.git//aws/sg"
  sg_name = "backend-sg-test"
  vpc_id = module.vpc.vpc_id
  ingresses = [{
    from = 22
    to = 22
    protocol = "TCP"
    cidr = module.default_vpc.private_subnet_cidrs
    sg = []
  }]
  description = "backend VPC test instance"
}

module "backend_test" {
  source = "git@github.com:ytensor42/tf-modules.git//aws/ec2"
  instance_name = "backend-test"
  domain_zone = data.aws_route53_zone.zone
  ami_type = "ubuntu-2204"
  instance_type = "t3.micro"
  key_name = "ec2_rsa"
  iam_instance_profile = "instance-profile-ssm"
  user_data = "ubuntu-default"
  aws_subnet_id = module.vpc.private_subnet_ids[0]
  vpc_security_group_ids = [ module.sg_backend_test.id ]
  volume_size = 8
}
