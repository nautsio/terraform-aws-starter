variable "vpc_id" {
}

variable "vpc_cidr" {
}

variable "ssh_security_groups" {
  type    = "list"
  default = []
}

variable "es_cluster_security_groups" {
  type    = "list"
  default = []
}

variable "vpc_subnets" {
  type = "list"
}

variable "ami_id" {
}

variable "instance_type" {
  default = "c3.2xlarge"
}

variable "zone_id" {
}

variable "key_name" {
}
