variable "name" {
  default = "private"
}

variable "cidrs" {
  description = "A list of CIDR"
  default     = []
}

variable "azs" {
  description = "A list of availability zones"
  default     = []
}

variable "vpc_id" {
}
