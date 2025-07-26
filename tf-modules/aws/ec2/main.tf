resource "aws_instance" "instance" {
  ami = var.ami == null ? local.ami_dict[var.ami_type] : var.ami
  instance_type = var.instance_type
  key_name = var.key_name
  iam_instance_profile = var.iam_instance_profile
  associate_public_ip_address = var.associate_public_ip_address
  subnet_id = var.aws_subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }
  tags = {
    Name = var.instance_name
  }
  metadata_options {
    http_tokens = var.http_tokens
  }
  user_data = local.user_data_dict[var.user_data]
}

#data "aws_route53_zone" "domain_zone" {
#  name = var.domain_zone["name"]
#  private_zone = true
#}

resource "aws_route53_record" "instance" {
  count = var.domain_zone == null ? 0:1
  zone_id = var.domain_zone["id"]
  name = "${var.instance_name}.${var.domain_zone["name"]}"
  type = "CNAME"
  ttl = "300"
  records = [ aws_instance.instance.private_dns ]
}
