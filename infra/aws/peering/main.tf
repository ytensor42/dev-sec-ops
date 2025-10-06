terraform {
  backend "s3" {
    bucket = "ytensor42-common"
    key = "terraform-state/peering/tfstate"
    region = "us-west-2"
  }
}

provider "aws" {
  region = "us-west-2" 
}

###
variable "hc_cidr" {
    type = string
    default = "73.93.186.146/32"
}

data "aws_route53_zone" "zone" {
  name = "demo.ansolute.com"
  private_zone = true
}

### default VPC
variable "vpc_name" {
    type = string
    default = "default"
}

module "default_vpc" {
  source = "git@github.com:ytensor42/tf-modules.git//aws/data/vpc"
  vpc_name = var.vpc_name
}

### default SSM VPCE
module "vpce" {
  source = "git@github.com:ytensor42/tf-modules.git//aws/vpce/ssm" 
  vpc_name = "default"
  network_type = "private"
}

### peer VPC
module "vpc" {
  source = "git@github.com:ytensor42/tf-modules.git//aws/vpc"
  vpc_name = "backend"
  vpc_cidr = "172.21.0.0/16"
  public_subnet = 0
  private_subnet = 2
  nat_gw = false
  nat_gw_multi = false
  ssm_vpce = true
}

### Peering
resource "aws_vpc_peering_connection" "peer" {
  vpc_id = module.default_vpc.vpc_id
  peer_vpc_id = module.vpc.vpc_id
  auto_accept = true  # valid for same account & region
  tags = {
    Name = "Peering-default-to-backend"
  }
}

### Routes (default to peer)
locals {
  dtp_route_pairs = flatten([
    for rt_id in toset(module.default_vpc.private_rt_ids) : [
      for cidr in toset(module.vpc.private_subnet_cidrs) : {
        rt_id = rt_id
        cidr  = cidr
      }
    ]
  ])
}

resource "aws_route" "default_to_peer" {
  for_each = {
    for pair in local.dtp_route_pairs: "${pair.rt_id}-${replace(pair.cidr, "/", "-")}" => pair
  }
  route_table_id = each.value.rt_id
  destination_cidr_block = each.value.cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

### Routes (peer to default)
locals {
  ptd_route_pairs = flatten([
    for rt_id in toset(module.vpc.private_rt_ids) : [
      for cidr in toset(module.default_vpc.private_subnet_cidrs) : {
        rt_id = rt_id
        cidr  = cidr
      }
    ]
  ])
}

resource "aws_route" "peer_to_default" {
  for_each = {
    for pair in local.ptd_route_pairs: "${pair.rt_id}-${replace(pair.cidr, "/", "-")}" => pair
  }
  route_table_id = each.value.rt_id
  destination_cidr_block = each.value.cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

### EC2
module "sg_default_test" {
  source = "git@github.com:ytensor42/tf-modules.git//aws/sg"
  sg_name = "default-sg-test"
  vpc_id = module.default_vpc.vpc_id
  ingresses = [{
    from = 22
    to = 22
    protocol = "TCP"
    cidr = module.vpc.private_subnet_cidrs
    sg = []
  }]
  description = "default VPC test instance"
}

module "default_test" {
  source = "git@github.com:ytensor42/tf-modules.git//aws/ec2"
  instance_name = "default-test"
  domain_zone = data.aws_route53_zone.zone
  ami_type = "ubuntu-2204"
  instance_type = "t3.micro"
  key_name = "ec2_rsa"
  iam_instance_profile = "instance-profile-ssm"
  user_data = "ubuntu-default"
  aws_subnet_id = module.default_vpc.private_subnet_ids[0]
  vpc_security_group_ids = [ module.sg_default_test.id ]
  volume_size = 8
}

module "sg_backend_test" {
  source = "git@github.com:ytensor42/tf-modules.git//aws/sg"
  sg_name = "backend-sg-test"
  vpc_id = module.vpc.vpc_id
  ingresses = [{
    from = 22
    to = 22
    protocol = "TCP"
    cidr = module.default_vpc.private_subnet_cidrs
    sg = []
  }]
  description = "backend VPC test instance"
}

module "backend_test" {
  source = "git@github.com:ytensor42/tf-modules.git//aws/ec2"
  instance_name = "backend-test"
  domain_zone = data.aws_route53_zone.zone
  ami_type = "ubuntu-2204"
  instance_type = "t3.micro"
  key_name = "ec2_rsa"
  iam_instance_profile = "instance-profile-ssm"
  user_data = "ubuntu-default"
  aws_subnet_id = module.vpc.private_subnet_ids[0]
  vpc_security_group_ids = [ module.sg_backend_test.id ]
  volume_size = 8
}
