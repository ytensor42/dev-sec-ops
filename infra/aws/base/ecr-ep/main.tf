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
module "interface" {
  source = "<module_base>/aws/vpce/interface"
  endpoint = "ecr"
  vpc_name = "default"
  network_name = "private"
}
