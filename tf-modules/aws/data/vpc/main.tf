variable "vpc_name" {
  type = string
  default = "default"
}

data "aws_vpc" "vpc" {
  tags = { 
    Name = var.vpc_name
  }
}

data "aws_subnets" "subnets" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
}

data "aws_subnet" "subnets" {
  for_each = toset(data.aws_subnets.subnets.ids)
  id = each.value
}

data "aws_route_tables" "public_rt" {
  vpc_id = data.aws_vpc.vpc.id
  filter {
    name   = "tag:Name"
    values = ["${var.vpc_name}-rtb-public"]
  }
}

data "aws_route_tables" "private_rt" {
  vpc_id = data.aws_vpc.vpc.id
  filter {
    name   = "tag:Name"
    values = ["${var.vpc_name}-rtb-private*"]
  }
}

output "vpc_id" {
  value = data.aws_vpc.vpc.id
}

output "cidr_block" {
  value = data.aws_vpc.vpc.cidr_block
}

output "subnet_ids" {
  value = [for s in data.aws_subnet.subnets: s.id if strcontains(s.tags["Name"], var.vpc_name)]
  depends_on = [ data.aws_subnets.subnets ]
}

output "subnet_cidrs" {
  value = [for s in data.aws_subnet.subnets: s.cidr_block if strcontains(s.tags["Name"], var.vpc_name)]
  depends_on = [ data.aws_subnets.subnets ]
}

output "rt_ids" {
  value = concat(data.aws_route_tables.public_rt.ids, data.aws_route_tables.private_rt.ids)
}

output "public_subnet_availability_zone" {
  value = [for s in data.aws_subnet.subnets: s.availability_zone if strcontains(s.tags["Name"], "-public-")]
  depends_on = [ data.aws_subnets.subnets ]
}

output "public_subnet_ids" {
  value = [for s in data.aws_subnet.subnets: s.id if strcontains(s.tags["Name"], "-public-")]
  depends_on = [ data.aws_subnets.subnets ]
}

output "public_subnet_cidrs" {
  value = [for s in data.aws_subnet.subnets: s.cidr_block if strcontains(s.tags["Name"], "-public-")]
  depends_on = [ data.aws_subnets.subnets ]
}

output "public_rt_ids" {
  value = data.aws_route_tables.public_rt.ids
  depends_on = [ data.aws_route_tables.public_rt ]
}

output "private_subnet_availability_zone" {
  value = [for s in data.aws_subnet.subnets: s.availability_zone if strcontains(s.tags["Name"], "-private-")]
  depends_on = [ data.aws_subnets.subnets ]
}

output "private_subnet_ids" {
  value = [for s in data.aws_subnet.subnets: s.id if strcontains(s.tags["Name"], "-private-")]
  depends_on = [ data.aws_subnets.subnets ]
}

output "private_subnet_cidrs" {
  value = [for s in data.aws_subnet.subnets: s.cidr_block if strcontains(s.tags["Name"], "-private-")]
  depends_on = [ data.aws_subnets.subnets ]
}

output "private_rt_ids" {
  value = data.aws_route_tables.private_rt.ids
  depends_on = [ data.aws_route_tables.private_rt ]
}