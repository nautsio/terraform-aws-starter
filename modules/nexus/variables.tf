variable "vpc_id" {}

variable "vpc_subnets" {
  type = "list"
}

variable "ami_id" {}

variable "instance_type" {
  default = "t2.medium"
}

variable "zone_id" {}

variable "allowed_cidr_blocks" {
  type    = "list"
  default = []
}

variable "ssh_security_groups" {
  type    = "list"
  default = []
}

variable "nexus_ebs_snapshot_id" {
  default = "snap-c6f014bf"
}

variable "azs" {
  type = "list"
}

variable "env" {}

variable "key_name" {}
