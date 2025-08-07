output "alb_dns_name" {
    value = module.ecs_fargate.alb_dns_name
}

output "private_dns_name" {
    value = module.instance.private_dns_name
}
