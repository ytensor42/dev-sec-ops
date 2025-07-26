output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnet_ids" {
  value = concat(aws_subnet.public[*].id, aws_subnet.private[*].id)
}

output "subnet_cidrs" {
  value = concat(aws_subnet.public[*].cidr_block, aws_subnet.private[*].cidr_block)
}

output "rt_ids" {
  value = concat(aws_route_table.public[*].id, aws_route_table.private[*].id)
}

## public subnets
output "public_subnet_availability_zone" {
  value = aws_subnet.public[*].availability_zone
  depends_on = [ aws_subnet.public ]
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
  depends_on = [ aws_subnet.public ]
}

output "public_subnet_cidrs" {
  value = aws_subnet.public[*].cidr_block
  depends_on = [ aws_subnet.public ]
}

output "public_rt_ids" {
  value = aws_route_table.public[*].id
  depends_on = [ aws_subnet.public ]
}

## private subnets
output "private_subnet_availability_zone" {
  value = aws_subnet.private[*].availability_zone
  depends_on = [ aws_subnet.private ]
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
  depends_on = [ aws_subnet.private ]
}

output "private_subnet_cidrs" {
  value = aws_subnet.private[*].cidr_block
  depends_on = [ aws_subnet.private ]
}

output "private_rt_ids" {
  value = aws_route_table.private[*].id
  depends_on = [ aws_subnet.private ]
}