# Route53 new environment zone record
resource "aws_route53_zone" "hosted_zone" {
  name = "${var.sub_domain}.${var.root_domain}"

  dynamic "vpc" {
    for_each = var.vpc_id
    content {
      vpc_id = vpc.value
    }
  }
}

resource "aws_route53_record" "ns_delegation" {
  count   = var.delegation ? 1:0
  zone_id = data.aws_route53_zone.root_domain_zone[0].zone_id
  name    = aws_route53_zone.hosted_zone.name
  type    = "NS"
  ttl     = "30"

  records = [
    aws_route53_zone.hosted_zone.name_servers.0,
    aws_route53_zone.hosted_zone.name_servers.1,
    aws_route53_zone.hosted_zone.name_servers.2,
    aws_route53_zone.hosted_zone.name_servers.3
  ]
}
