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
variable "vpc_name" { default = "default" }
variable "rds_name" { default = "dev-postgres" }
variable "security_group_cidrs" { default = [ "10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16" ] }
variable "security_group_ids" { default = [] }
variable "rds_dev_secret_name" { default = "secret-test-string" }

module "vpc" {
  source = "<module_base>/aws/data/vpc"
  vpc_name = var.vpc_name
}

data "aws_route53_zone" "zone" {
  name = "demo.aws.ansolute.com"
}

data "aws_secretsmanager_secret" "secret" {
  name = var.rds_dev_secret_name
}

data "aws_secretsmanager_secret_version" "secret" {
  secret_id = data.aws_secretsmanager_secret.secret.id
}

locals {
  secret = jsondecode(data.aws_secretsmanager_secret_version.secret.secret_string)
  #db_host = local.secret["DB_HOST"]
  db_port = local.secret["DB_PORT"]
  db_name = local.secret["DB_NAME"]
  db_user = local.secret["DB_USER"]
  db_password = local.secret["DB_PASSWORD"]
}

## RDS
resource "aws_db_subnet_group" "rds" {
  name       = "${var.vpc_name}-sbng-rds-postgres"
  subnet_ids = module.vpc.private_subnet_ids
  tags = {
    Name = "${var.vpc_name}-sbng-rds-postgres"
  }
}

resource "aws_security_group" "sg_rds" {
  name        = "${var.vpc_name}-sg-rds-postgres"
  description = "Allow access to PostgreSQL"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = local.db_port
    to_port     = local.db_port
    protocol    = "tcp"
    cidr_blocks = var.security_group_cidrs
    security_groups = var.security_group_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.vpc_name}-sg-rds-postgres"
  }
}

resource "aws_db_instance" "postgres" {
  identifier              = var.rds_name
  engine                  = "postgres"
  engine_version          = "17.5"
  instance_class          = "db.t3.micro"
  ca_cert_identifier      = "rds-ca-rsa2048-g1"
  allocated_storage       = 20
  storage_type            = "gp2"
  storage_encrypted       = true
  db_subnet_group_name    = aws_db_subnet_group.rds.name
  vpc_security_group_ids  = [aws_security_group.sg_rds.id]
  publicly_accessible     = false
  skip_final_snapshot     = true
  db_name                 = local.db_name
  username                = local.db_user
  password                = local.db_password
  port                    = local.db_port
  parameter_group_name    = "default.postgres17"
  network_type            = "IPV4"
  multi_az                = false
  backup_retention_period = 0
  auto_minor_version_upgrade = true
  maintenance_window      = "sun:03:00-sun:04:00"
  deletion_protection     = false
  performance_insights_enabled = false
  monitoring_interval     = 0
  tags = {
    Name = "${var.vpc_name}-sg-rds-postgres"
  }
}

resource "aws_route53_record" "postgres" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name = "${var.rds_name}.${data.aws_route53_zone.zone.name}"
  type = "CNAME"
  ttl = "300"
  records = [ aws_db_instance.postgres.address ]
}

output "address" {
  value = aws_db_instance.postgres.address
}

output "fqdn" {
  value = aws_route53_record.postgres.fqdn
}