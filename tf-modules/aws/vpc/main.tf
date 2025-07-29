resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = "true"
  enable_dns_support = "true"
  tags = {
    Name = "${var.vpc_name}"
  }
}

# subnets

resource "aws_subnet" "public" {
  count = var.public_subnet
  vpc_id = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 4, count.index)
  availability_zone = "${var.region}${local.zones[count.index]}"
  tags = {
    Name = "${var.vpc_name}-subnet-public-${local.zones[count.index]}"
  }
}

resource "aws_subnet" "private" {
  count = var.private_subnet
  vpc_id = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 4, count.index + 8)
  availability_zone = "${var.region}${local.zones[count.index]}"
  tags = {
    Name = "${var.vpc_name}-subnet-private-${local.zones[count.index]}"
  }
}

# gateways

resource "aws_internet_gateway" "igw" {
  count = var.public_subnet != 0 ? 1:0
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_eip" "nat_eip" {
  count = (var.nat_gw && var.private_subnet != 0 && var.public_subnet != 0) ? (var.nat_gw_multi ? var.private_subnet:1):0
  domain = "vpc"
  depends_on = [aws_internet_gateway.igw[0]]
  tags = {
    Name = "${var.vpc_name}-nat-eip-${local.zones[count.index]}"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  count = length(aws_eip.nat_eip[*])
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id = aws_subnet.public[count.index].id
  tags = {
    Name = "${var.vpc_name}-nat-gw-${local.zones[count.index]}"
  }
}


# Default security group

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id
  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.vpc_name}-sg-default"
  }
}

# Route tables / Routes

resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
  tags = {
    Name = "${var.vpc_name}-rtb-default"
  }
}

resource "aws_route_table" "public" {
  count = var.public_subnet != 0 ? 1:0
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw[0].id
  }
  tags = {
    Name = "${var.vpc_name}-rtb-public-all"
  }
}

resource "aws_route_table_association" "public" {
  count = var.public_subnet
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table" "private" {
  count = var.private_subnet
  vpc_id = aws_vpc.vpc.id
  dynamic "route" {
    for_each = (var.nat_gw && var.public_subnet != 0) ? [1]:[]
    content {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.nat_gw[var.nat_gw_multi ? count.index:0].id
    }
  }
  tags = {
    Name = "${var.vpc_name}-rtb-private-${local.zones[count.index]}"
  }
}

resource "aws_route_table_association" "private" {
  count = var.private_subnet
  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

#resource "aws_vpc_endpoint_route_table_association" "public" {
#  count = (var.public_subnet != 0 && var.private_subnet == 0) ? 1:0
#  route_table_id  = aws_route_table.public[0].id
#  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
#}
#
#resource "aws_vpc_endpoint_route_table_association" "private" {
#  count = var.private_subnet
#  route_table_id  = aws_route_table.private[count.index].id
#  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
#}

#resource "aws_vpc_endpoint" "s3" {
#  count = (var.public_subnet != 0 || var.private_subnet != 0) ? 1:0
#  vpc_id = aws_vpc.vpc.id
#  service_name = "com.amazonaws.${var.region}.s3"
#  tags = {
#    Name = "${var.vpc_name}-vpce-s3"
#  }
#}

## S3 VPC Endpoint
module "vpce_s3" {
  count  = (var.public_subnet != 0 || var.private_subnet != 0) ? 1:0

  source = "git@github.com:ytensor42/demos.git//tf-modules/aws/vpce/gateway" 
  vpc_name = var.vpc_name
  endpoint = "s3"
  network_name = "private"
}

## SSM VPC Endpoints
module "vpce_ssm" {
  count  = (var.private_subnet != 0 && var.ssm_vpce) ? 1:0

  source = "git@github.com:ytensor42/demos.git//tf-modules/aws/vpce/interface" 
  vpc_name = var.vpc_name
  endpoint = "ssm"
  network_name = "private"
}
