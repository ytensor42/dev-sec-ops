variable "vpc_id" {
  type = string
  default = null
}

variable "vpc_name" {
  type = string
  default = null
}

variable "app_name" {
  type = string
  default = null
}

variable "execution_role_arn" {
  type = string
  default = null
}

variable "cpu_architecture" {
  type = string
  default = "X86_64" # or "ARM64"
}

variable "ecr_repo_url" {
  type = string
  default = null
}

variable "image_tag" {
  type = string
  default = null
}

variable "db_host" {
  type = string
  default = null
}

variable "private_subnet_ids" {
  type = list(string)
  default = []
}

variable "public_subnet_ids" {
  type = list(string)
  default = []
}

variable "task_sg_ids" {
  type = list
  default = []
}

variable "alb_sg_ids" {
  type = list
  default = []
}
