variable "vpc_id" {}

variable "vpc_subnets" {
  type = "list"
}

variable "vpc_security_groups" {
  default = []
}

variable "app_security_groups" {
  default = []
}

variable "vpc_cidr_blocks" {
  default = []
}

variable "bastion_sg_id" {
  default = ""
}

variable "ami_id" {}

variable "key_name" {}

variable "zone_id" {}

variable "node_count" {
  default = 3
}

variable "disable_api_termination" {
  default = true
}

variable "node_instance_type" {
  default = "t2.medium"
}

variable "env" {}

variable "azs" {
  type = "list"
}
