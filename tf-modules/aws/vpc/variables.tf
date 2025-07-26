variable "region" {
    type = string
    default = "us-west-2"
}

variable "vpc_name" {
    type = string
    default = "default"
}

variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
}

variable "public_subnet" {
    type = number
    default = 0
}

variable "private_subnet" {
    type = number
    default = 0
}

variable "nat_gw" {
    type = bool
    default = false
}

variable "nat_gw_multi" {
    type = bool
    default = false
}

variable "ssm_vpce" {
    type = bool
    default = false
}

locals {
    zones = [ "a", "b", "c", "d" ]
    ssm_endpoints = [
        "ssm",
        "ssmmessages",
        "ec2messages"
    ]
    public_cidrs = [ for i in range(var.public_subnet): cidrsubnet(var.vpc_cidr, 4, i) ]
    public_zones = [ for i in range(var.public_subnet): "${var.region}${local.zones[i]}" ]
    private_cidrs = [ for i in range(var.private_subnet): cidrsubnet(var.vpc_cidr, 4, i + 8) ]
    private_zones = [ for i in range(var.private_subnet): "${var.region}${local.zones[i]}" ]
}
