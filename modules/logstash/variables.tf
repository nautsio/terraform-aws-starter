variable "vpc_id" {
}

variable "vpc_subnets" {
  type = "list"
}

variable "image_id" {
}

variable "instance_type" {
  default = "m4.large"
}

variable "zone_id" {
}

variable "key_name" {
}

variable "vpc_cidr_blocks" {
  type = "list"
}

variable "vpc_security_groups" {
  type = "list"
}
