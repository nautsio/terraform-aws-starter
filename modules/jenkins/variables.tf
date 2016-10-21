variable "vpc_id" {
}

variable "vpc_cidr" {
}

variable "vpc_subnets" {
  type = "list"
}

variable "vpc_security_groups" {
  default = []
}

variable "ami_id" {
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
}

variable "zone_id" {
}
