variable "domain_name" {
  type = string
  default = ""
}

variable "private_zone" {
  type = bool
  default = true
}

data "aws_route53_zone" "zone" {
  name = var.domain_name
  private_zone = var.private_zone
}

output "zone" {
  value = {
    "id": data.aws_route53_zone.zone.zone_id,
    "name": data.aws_route53_zone.zone.name,
  }
}
