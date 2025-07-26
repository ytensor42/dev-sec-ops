data "aws_route53_zone" "root_domain_zone" {
  count = var.delegation ? 1:0
  name = var.root_domain
  private_zone = var.vpc_id != [] ? true : false
}
