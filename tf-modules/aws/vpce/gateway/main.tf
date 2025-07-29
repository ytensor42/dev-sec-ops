variable "region" {
  type = string
  default = "us-west-2"
}

variable "endpoint" {
  type = string
  default = "s3"
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

data "aws_route_tables" "rts" {
  vpc_id = data.aws_vpc.vpc.id
  filter {
    name = "tag:Name"    
    values = ["${var.vpc_name}-rtb-${var.network_name}-*"]
  }
}

locals {
  endpoints = {
    "s3" = [ "s3" ]
  }
  vpce_route_pairs = flatten([
    for vpce_id in toset(aws_vpc_endpoint.endpoint[*].id) : [
      for rt_id in toset(data.aws_route_tables.rts.ids) : {
        vpce_id  = vpce_id
        rt_id = rt_id
      }
    ]
  ])
}

resource "aws_vpc_endpoint" "endpoint" {
  for_each = toset(local.endpoints[var.endpoint])

  vpc_id            = data.aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.region}.${each.key}"
  vpc_endpoint_type = "Gateway"
  tags = { Name = "${var.vpc_name}-vpce-${each.key}" }
}

resource "aws_vpc_endpoint_route_table_association" "rt_association" {
  count = length(data.aws_route_tables.rts.ids)
  for_each = {
    for pair in local.vpce_route_pairs: "${pair.vpce_id}-${pair.rt_id}" => pair
  }

  route_table_id  = each.value.rt_id
  vpc_endpoint_id = each.value.vpce_id
}