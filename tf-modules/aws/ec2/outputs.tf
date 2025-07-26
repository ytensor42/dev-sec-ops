output "id" {
  value = aws_instance.instance.id
}

output "ami" {
  value = aws_instance.instance.ami
}

output "private_ip" {
  value = aws_instance.instance.private_ip
}

output "private_dns_name" {
  value = aws_instance.instance.private_dns
}

output "public_ip" {
  value = aws_instance.instance.public_ip
}

output "public_dns_name" {
  value = aws_instance.instance.public_dns
}

output "vpc_security_group_ids" {
  value = aws_instance.instance.vpc_security_group_ids
}

output "subnet_id" {
  value = aws_instance.instance.subnet_id
}

output "availability_zone" {
  value = aws_instance.instance.availability_zone
}

#output "all_info" {
#  value = aws_instance.instance
#}