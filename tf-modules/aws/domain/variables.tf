variable "root_domain" {
  default = "aws.ansolute.com"
}

variable "sub_domain" {
  default = "demo"
}

variable "delegation" {
  type = bool
  default = false
}

variable "vpc_id" {
  default = []
}
