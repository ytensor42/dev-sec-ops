output "alb_dns_name" {
  value = aws_lb.app.dns_name
}

output "service_url" {
  value = "https://${var.app_name}.${data.aws_route53_zone.zone.name}"
  depends_on = [data.aws_route53_zone.zone]
}
