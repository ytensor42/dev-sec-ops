terraform {
  backend "s3" {
    bucket = "<s3_bucket>"
    key = "<tfstate_key>"
    region = "<aws_region>"
  }
}

provider "aws" {
  region = "<aws_region>" 
}

#############################################################
variable "vpc_name" { default = "<vpc_name>" }

module "vpc" {
  source = "<module_base>/aws/vpc"
  vpc_name = var.vpc_name
  vpc_cidr = "172.16.0.0/16"
  public_subnet = 2
  private_subnet = 2
  nat_gw = false
  nat_gw_multi = false
  ssm_vpce = false
}

#module "domain" {
#  source = "<module_base>/aws/domain"
#  root_domain = "aws.ansolute.com"
#  sub_domain = "demo"
#  delegation = true
#}

resource "aws_iam_policy" "s3_policy" {
  name        = "S3-RW-<s3_bucket>-<config_key>"
  path        = "/"
  description = "S3 RW for <s3_bucket>/<config_key>"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = "arn:aws:s3:::<s3_bucket>"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::<s3_bucket>/<config_key>/*"
      }
    ]
  })
}

module "instance_profile_ssm_ecr" {
  source = "<module_base>/aws/role/instance_profile"
  name_postfix = "ssm-ecr"
  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds",
    "arn:aws:iam::<account_id>:policy/S3-RW-<s3_bucket>-<config_key>"
  ]
  depends_on = [aws_iam_policy.s3_policy]
}

module "instance_profile_ssm" {
  source = "<module_base>/aws/role/instance_profile"
  name_postfix = "ssm"
  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::<account_id>:policy/S3-RW-<s3_bucket>-<config_key>"
  ]
  depends_on = [aws_iam_policy.s3_policy]
}
