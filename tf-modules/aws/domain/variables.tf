variable "root_domain" {
  default = "aws.ansolute.com"
}

variable "sub_domain" {
  default = "aws"
}

variable "delegation" {
  type = bool
  default = false
}

variable "vpc_id" {
  default = []
}
