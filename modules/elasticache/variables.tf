variable "name" {
}

variable "vpc_id" {
}

variable "node_type" {
  default = "cache.t2.micro"
}

variable "subnets" {
  type = "list"
}

variable "security_groups" {
  type = "list"
}
