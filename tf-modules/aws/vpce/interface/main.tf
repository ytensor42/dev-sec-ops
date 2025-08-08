variable "region" {
  type = string
  default = "us-west-2"
}

variable "endpoint" {
  type = string
  default = "ssm"
}

variable "vpc_name" {
  type = string
  default = "default"
}

variable "network_name" {
  type = string
  default = "private"
}

data "aws_vpc" "vpc" {
  tags = {
    Name = var.vpc_name
  }
}

data "aws_subnets" "network" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
  filter {
    name = "tag:Name"    
    values = ["${var.vpc_name}-subnet-${var.network_name}-*"]
  }
}

data "aws_subnet" "network" {
  for_each = toset(data.aws_subnets.network.ids)
  id = each.value
}

locals {
  network_cidrs = [for s in data.aws_subnet.network : s.cidr_block]
  endpoints = {
    "ssm" = [ "ssm", "ssmmessages", "ec2messages" ]
    "ecr" = [ "ecr.api", "ecr.dkr" ]
    "sm"  = [ "secretsmanager" ]
  }
}

resource "aws_security_group" "sg" {
  name = "${var.vpc_name}-sg-${var.endpoint}"
  vpc_id = data.aws_vpc.vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = local.network_cidrs
  }
  tags = { Name = "${var.vpc_name}-sg-${var.endpoint}" }
}

resource "aws_vpc_endpoint" "endpoint" {
  for_each = length(aws_security_group.sg) == 0 ? []:toset(local.endpoints[var.endpoint])

  vpc_id              = data.aws_vpc.vpc.id
  service_name        = "com.amazonaws.${var.region}.${each.key}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = data.aws_subnets.network.ids
  security_group_ids  = [aws_security_group.sg.id]
  private_dns_enabled = true
  tags = { Name = "${var.vpc_name}-vpce-${each.key}" }
}
