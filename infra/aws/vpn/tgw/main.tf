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

variable "vpc1_id" { default = "<vpc1_id>" }
variable "vpc2_id" { default = "<vpc2_id>" }
variable "vpc1_subnet_ids" { default = "<vpc1_subnet_ids>" }
variable "vpc2_subnet_ids" { default = "<vpc2_subnet_ids>" }
variable "vpc1_destination_cidr_block" { default = "<vpc1_destination_cidr_block>" }
variable "vpc2_destination_cidr_block" { default = "<vpc2_destination_cidr_block>" }
variable "ip_address" { default = "<ip_address>" }

resource "aws_ec2_transit_gateway" "main" {
  description = "main"
}

resource "aws_customer_gateway" "cgw" {
  bgp_asn    = 65000
  ip_address = var.ip_address   # customer gateway ip
  type       = "ipsec.1"
}

resource "aws_vpn_connection" "vpn" {
  customer_gateway_id = aws_customer_gateway.cgw.id
  transit_gateway_id  = aws_ec2_transit_gateway.main.id
  type                = "ipsec.1"
  static_routes_only  = true
}

resource "aws_ec2_transit_gateway_vpc_attachment" "attachment1" {
  subnet_ids         = var.vpc1_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = var.vpc1_id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "attachment2" {
  subnet_ids         = var.vpc2_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = var.vpc2_id
}

resource "aws_ec2_transit_gateway_route_table" "rt" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
}

resource "aws_ec2_transit_gateway_route" "tgw_route1" {
  destination_cidr_block         = "<vpc1_destination_cidr_block>"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.attachment1.id
}

resource "aws_ec2_transit_gateway_route" "tgw_route2" {
  destination_cidr_block         = "<vpc2_destination_cidr_block>"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.attachment2.id
}

resource "aws_route" "vpc1_to_tgw" {
  route_table_id         = aws_route_table.private1.id
  destination_cidr_block = "<vpc1_destination_cidr_block>"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
}

resource "aws_route" "vpc2_to_tgw" {
  route_table_id         = aws_route_table.private2.id
  destination_cidr_block = "<vpc2_destination_cidr_block>"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
}
