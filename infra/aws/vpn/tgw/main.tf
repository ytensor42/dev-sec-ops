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
variable "tgw_secrets_name" { default = "<tgw_secrets_name>" }

module "vpc" {
  source = "<module_base>/aws/data/vpc"
  vpc_name = var.vpc_name
}

data "aws_secretsmanager_secret" "tgw_secret" {
  name = var.tgw_secrets_name
}

data "aws_secretsmanager_secret_version" "tgw_secret" {
  secret_id = data.aws_secretsmanager_secret.tgw_secret.id
}

resource "aws_ec2_transit_gateway" "main" {
  description = "main"
}

resource "aws_customer_gateway" "cgw" {
  bgp_asn    = 65000
  ip_address = var.remote_ip_address
  type       = "ipsec.1"
}

locals {
  vgw_secret = jsondecode(data.aws_secretsmanager_secret_version.tgw_secret.secret_string)
}

resource "aws_vpn_connection" "vpn" {
  customer_gateway_id = aws_customer_gateway.cgw.id
  transit_gateway_id  = aws_ec2_transit_gateway.main.id
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

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.subnet_ids
}

resource "aws_ec2_transit_gateway_route_table" "main" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
}

# Incoming VPN traffic to refer route table @ TGW 
resource "aws_ec2_transit_gateway_route_table_association" "vpn_assoc" {
  transit_gateway_attachment_id = aws_vpn_connection.vpn.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}

# Incoming VPC traffic to refer route table @ TGW
resource "aws_ec2_transit_gateway_route_table_association" "vpc_assoc" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.vpc.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}

# For dynamic routing, BGP
resource "aws_ec2_transit_gateway_route_table_propagation" "vpn_propagation" {
  transit_gateway_attachment_id  = aws_vpn_connection.vpn.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}

# From VPN to VPC
resource "aws_ec2_transit_gateway_route" "vpc_route" {
  destination_cidr_block         = module.vpc.cidr_block
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc.id
}

# From VPC to VPN
resource "aws_ec2_transit_gateway_route" "vpn_route" {
  destination_cidr_block         = var.remote_cidr_block   # remote cidr
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
  transit_gateway_attachment_id  = aws_vpn_connection.vpn.transit_gateway_attachment_id
}

# VPC internal to TGW
resource "aws_route" "vpc_to_tgw" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = var.remote_cidr_block           # remote cidr
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
}
