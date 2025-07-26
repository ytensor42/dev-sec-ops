variable "instance_name" {
  type = string
  default = null
}

data "aws_instance" "instance" {
  filter {
    name   = "tag:Name"
    values = [var.instance_name]
  }
}

output "id" {
  value = data.aws_instance.instance.id
}

output "ami" {
  value = data.aws_instance.instance.ami
}

output "private_ip" {
  value = data.aws_instance.instance.private_ip
}

output "private_dns_name" {
  value = data.aws_instance.instance.private_dns
}

output "public_ip" {
  value = data.aws_instance.instance.public_ip
}

output "public_dns_name" {
  value = data.aws_instance.instance.public_dns
}

output "vpc_security_group_ids" {
  value = data.aws_instance.instance.vpc_security_group_ids
}

output "subnet_id" {
  value = data.aws_instance.instance.subnet_id
}

output "availability_zone" {
  value = data.aws_instance.instance.availability_zone
}

#output "all_info" {
#  value = data.aws_instance.instance
#}