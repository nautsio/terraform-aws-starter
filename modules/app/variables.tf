variable "vpc_id" {}

variable "vpc_subnets" {
  type = "list"
}

variable "desired_capacity" {
  default = 1
}

variable "max_size" {
  default = 1
}

variable "bastion_sg_id" {
  default = ""
}

variable "key_name" {}

variable "image_id" {
  default = ""
}

variable "instance_type" {
  default = ""
}

variable "root_volume_size" {
  default = "8"
}

variable "zone_id" {}

variable "env" {}

variable "vpc_security_groups" {
  default = []
}

variable "vpc_cidr_blocks" {
  default = []
}

variable "app_security_groups" {
  default = []
}

variable "alb_public_subnets" {
  default = []
}
