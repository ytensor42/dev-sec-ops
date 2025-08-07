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
variable "nat_gw_multi" { default = false }
locals {
  zones = [ "a", "b", "c", "d" ]
}

module "vpc" {
  source = "<module_base>/aws/data/vpc"
  vpc_name = var.vpc_name
}

resource "aws_eip" "nat_eip" {
  count = var.nat_gw_multi ? length(module.vpc.private_subnet_ids):1
  domain = "vpc"
  tags = {
    Name = "${var.vpc_name}-nat-eip-${local.zones[count.index]}"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  count = length(aws_eip.nat_eip[*])
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id = module.vpc.public_subnet_ids[count.index]
  tags = {
    Name = "${var.vpc_name}-nat-gw-${local.zones[count.index]}"
  }
}

resource "aws_route" "route" {
  count = length(aws_eip.nat_eip[*])
  route_table_id = module.vpc.private_rt_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat_gw[count.index].id
}
