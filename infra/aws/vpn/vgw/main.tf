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
variable "vpc_name" { default = "<vpc_name>" }
variable "ip_address" { default = "<ip_address>" }

module "vpc" {
  source = "<module_base>/aws/data/vpc"
  vpc_name = var.vpc_name
}

resource "aws_vpn_gateway" "vgw" {
  vpc_id = module.vpc.vpc_id
}

resource "aws_customer_gateway" "cgw" {
  bgp_asn    = 65000
  ip_address = var.ip_address
  type       = "ipsec.1"
}

resource "aws_vpn_connection" "vpn" {
  vpn_gateway_id      = aws_vpn_gateway.vgw.id
  customer_gateway_id = aws_customer_gateway.cgw.id
  type                = "ipsec.1"
  static_routes_only  = true
}

resource "aws_vpn_connection_route" "route" {
  vpn_connection_id      = aws_vpn_connection.vpn.id
  destination_cidr_block = module.vpc.cidr_block
}

resource "aws_route_table" "private_rt" {
  vpc_id = module.vpc.vpc_id

  route {
    cidr_block = module.vpc.cidr_block
    gateway_id = aws_vpn_gateway.vgw.id
  }
}
