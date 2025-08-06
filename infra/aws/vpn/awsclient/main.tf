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
variable "server_cert_arn" {
  default = "arn:aws:acm:us-west-2:119145547444:certificate/01179300-ab59-4150-aa85-9b28d06e7941"
}
variable "root_certificate_chain_arn" {
  default = "arn:aws:acm:us-west-2:119145547444:certificate/68a7a3f5-dfa5-4af0-8af5-0e7624abc84c"
}
variable "vpc_id" { }
variable "split_tunnel" {
  type = bool
  default = true
}
variable "subnet_id" { }
variable "client_cidr_block" { }
variable "target_cidr_block" { }

resource "aws_ec2_client_vpn_endpoint" "vpn" {
  description            = "AWS Client VPN"
  server_certificate_arn = var.server_cert_arn
  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = var.root_certificate_chain_arn
  }
  client_cidr_block      = var.client_cidr_block
  connection_log_options {
    enabled = false
  }
  split_tunnel           = var.split_tunnel
  vpc_id                 = var.vpc_id
  security_group_ids     = [aws_security_group.vpn_sg.id]
}

resource "aws_ec2_client_vpn_network_association" "assoc" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  subnet_id              = var.subnet_id
}

resource "aws_ec2_client_vpn_authorization_rule" "auth" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  target_network_cidr    = var.target_cidr_block
  authorize_all_groups   = true
}

resource "aws_ec2_client_vpn_route" "route" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  destination_cidr_block = var.target_cidr_block
  target_vpc_subnet_id   = var.subnet_id
}
