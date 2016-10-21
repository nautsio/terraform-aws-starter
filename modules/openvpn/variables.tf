variable "vpc_id" {}

variable "vpc_subnets" {
  type = "list"
}

variable "vpc_security_groups" {
  type    = "list"
  default = []
}

variable "node_instance_type" {
  default = "t2.micro"
}

variable "ami_id" {
  default = ""
}

variable "disable_api_termination" {
  default = false
}

variable "key_name" {}

variable "zone_id" {}
