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

resource "aws_security_group" "sg_default_dev" {
  name        = "${var.vpc_name}-default-dev"
  description = "Allow traffic for default-dev instance"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnet_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-sg-default-dev"
  }
}

module "instance" {
  source = "<module_base>/aws/ec2"
  instance_name = "default-dev"
  ami = "ami-061e8bd551e848afc"
  instance_type = "t3.micro"
  key_name = "ec2_rsa"
  iam_instance_profile = "instance-profile-ssm-ecr"
  user_data = "ubuntu-default"
  aws_subnet_id = module.vpc.private_subnet_ids[0]
  vpc_security_group_ids = [ aws_security_group.sg_default_dev.id ]
  volume_size = 20
}

output "instance" {
  value = module.instance
}
