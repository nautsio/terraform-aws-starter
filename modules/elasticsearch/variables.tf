variable "vpc_id" {}

variable "vpc_subnets" {
  type = "list"
}

variable "ssh_security_groups" {
  default = []
}

variable "es_cluster_security_groups" {
  default = []
}

variable "es_interface_security_groups" {
  default = []
}

variable "es_instance_security_groups" {
  default = []
}

variable "app_security_groups" {
  default = []
}

variable "es_mgmt_cidr_blocks" {
  default = []
}

variable "ami_id" {}

variable "key_name" {}

variable "zone_id" {}

variable "node_count" {
  default = 3
}

variable "disable_api_termination" {
  default = false
}

variable "node_instance_type" {
  default = "c3.large"
}

variable "env" {}
