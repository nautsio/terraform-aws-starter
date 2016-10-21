variable "vpc_id" {}

variable "vpc_subnets" {
  type = "list"
}

variable "image_id" {
  default = ""
}

variable "instance_type" {
  default = ""
}

variable "zone_id" {}

variable "key_name" {}
