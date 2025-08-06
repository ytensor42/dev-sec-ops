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
variable "remote_ip_address" { default = "<remote_ip_address>" }
variable "remote_cidr_block" { default = "<remote_cidr_block>" }
variable "vgw_secrets_name" { default = "<vgw_secrets_name>" }

module "vpc" {
  source = "<module_base>/aws/data/vpc"
  vpc_name = var.vpc_name
}

data "aws_secretsmanager_secret" "vgw_secret" {
  name = var.vgw_secrets_name
}

data "aws_secretsmanager_secret_version" "vgw_secret" {
  secret_id = data.aws_secretsmanager_secret.vgw_secret.id
}

resource "aws_vpn_gateway" "vgw" {
  vpc_id = module.vpc.vpc_id
  tags = {
    Name = "${var.vpc_name}-vpn-gateway"
  }
}

resource "aws_customer_gateway" "cgw" {
  bgp_asn    = 65000
  ip_address = var.remote_ip_address
  type       = "ipsec.1"
  tags = {
    Name = "customer-vpn-gateway"
  }
}

locals {
  vgw_secret = jsondecode(data.aws_secretsmanager_secret_version.vgw_secret.secret_string)
}

resource "aws_vpn_connection" "vpn" {
  vpn_gateway_id      = aws_vpn_gateway.vgw.id
  customer_gateway_id = aws_customer_gateway.cgw.id
  type                = "ipsec.1"
  static_routes_only  = false     # dynamic routing, BGP

  tunnel1_preshared_key = local.vgw_secret["tunnel1_preshared_key"]
  tunnel1_inside_cidr   = local.vgw_secret["tunnel1_inside_cidr"]

  tunnel2_preshared_key = local.vgw_secret["tunnel2_preshared_key"]
  tunnel2_inside_cidr   = local.vgw_secret["tunnel2_inside_cidr"]

  tags = {
    Name = "${var.vpc_name}-vpn-connection"
  }
}

#resource "aws_vpn_connection_route" "route" {    # only needed when `static_routes_only = true`
#  vpn_connection_id      = aws_vpn_connection.vpn.id
#  destination_cidr_block = module.vpc.cidr_block
#}

resource "aws_route" "to_vpn" {
  for_each               = toset(module.vpc.private_rt_ids)
  route_table_id         = each.key
  destination_cidr_block = var.remote_cidr_block
  gateway_id             = aws_vpn_gateway.vgw.id
}
