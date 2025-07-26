
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "public_subnet_cidrs" {
  value = module.vpc.public_subnet_cidrs
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "private_subnet_cidrs" {
  value = module.vpc.private_subnet_cidrs
}

output "zone" {
  value = module.domain.zone
}

output "instance_profile_ssm_ecr_profile_name" {
  value = module.instance_profile_ssm_ecr.profile_name
}

output "instance_profile_ssm_ecr_role_name" {
  value = module.instance_profile_ssm_ecr.role_name
}

output "instance_profile_ssm_profile_name" {
  value = module.instance_profile_ssm.profile_name
}

output "instance_profile_ssm_role_name" {
  value = module.instance_profile_ssm.role_name
}
