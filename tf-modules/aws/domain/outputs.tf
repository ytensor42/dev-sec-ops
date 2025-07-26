output "zone" {
  value = {
    "id": aws_route53_zone.hosted_zone.zone_id,
    "name": aws_route53_zone.hosted_zone.name,
  }
}
