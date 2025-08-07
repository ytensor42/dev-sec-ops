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

module "vpc" {
  source = "<module_base>/aws/data/vpc"
  vpc_name = var.vpc_name
}

module "vpce" {
  source = "<module_base>/aws/vpce/ssm" 
  vpc_name = var.vpc_name
  network_type = "private"
}

resource "aws_security_group" "sg_default_tester" {
  name        = "${var.vpc_name}-default-tester"
  description = "Allow traffic for default-tester instance"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = module.vpc.subnet_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-sg-default-tester"
  }
}

module "instance" {
  source = "<module_base>/aws/ec2"
  instance_name = "default-tester"
  ami_type = "ubuntu-2204"
  instance_type = "t3.micro"
  key_name = "ec2_rsa"
  iam_instance_profile = "instance-profile-ssm"
  user_data = "ubuntu-default"
  aws_subnet_id = module.vpc.private_subnet_ids[0]
  vpc_security_group_ids = [ aws_security_group.sg_default_tester.id ]
  volume_size = 8
}
