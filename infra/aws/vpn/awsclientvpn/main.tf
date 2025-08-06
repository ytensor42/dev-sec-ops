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
variable "server_certificate_arn" { default = "<server_certificate_arn>" }
variable "root_certificate_chain_arn" { default = "<root_certificate_chain_arn>" }
variable "split_tunnel" { default = true }
variable "dns_zone_name" { default = "<dns_zone_name>" }

module "vpc" {
  source = "<module_base>/aws/data/vpc"
  vpc_name = var.vpc_name
}

resource "aws_security_group" "client_vpn_sg" {
  name        = "${var.vpc_name}-client-vpn-ep-sg"
  description = "Allow OpenVPN client traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-client-vpn-ep-sg"
  }
}

resource "aws_ec2_client_vpn_endpoint" "vpn" {
  description            = "AWS Client VPN"
  server_certificate_arn = var.server_certificate_arn
  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = var.root_certificate_chain_arn
  }
  client_cidr_block      = cidrsubnet(module.vpc.cidr_block, 4, 10)
  connection_log_options {
    enabled = false
  }
  split_tunnel           = var.split_tunnel
  vpc_id                 = module.vpc.vpc_id
  security_group_ids     = [aws_security_group.client_vpn_sg.id]
}

resource "aws_ec2_client_vpn_network_association" "assoc" {
  for_each               = toset(module.vpc.private_subnet_ids)
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  subnet_id              = each.key
}

locals {
    vpc_cidr_block = cidrsubnet(module.vpc.cidr_block, 3, 4)    # cover 8,9th /20 blocks
}

resource "aws_ec2_client_vpn_route" "route" {
  for_each               = toset(module.vpc.private_subnet_ids)
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  destination_cidr_block = local.vpc_cidr_block
  target_vpc_subnet_id   = each.key
}

resource "aws_ec2_client_vpn_authorization_rule" "auth" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  target_network_cidr    = local.vpc_cidr_block
  authorize_all_groups   = true
}

data "aws_route53_zone" "zone" {
  name = var.dns_zone_name
}

resource "aws_route53_record" "vpn_dns" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "vpn.${var.dns_zone_name}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_ec2_client_vpn_endpoint.vpn.dns_name]
}