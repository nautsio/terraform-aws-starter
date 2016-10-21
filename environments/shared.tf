# This file contains shared variables that almost all environments need.

variable azs {
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable vpc_name {
  default = "vpc"
}

variable vpc_cidr {
  default = "10.0.0.0/16"
}

# Account identifier of the management environment.
variable management_account_id {
  default = ""
}

# Base ami id for VM's.
variable base_ami_id {
  default = ""
}

# Top-level domain for public services.
variable domain {
  default = ""
}

# Cidr blocks for the public subnets in the VPC (count = number of AZ's)
variable public_subnet_cidrs {
  type    = "list"
  default = []
}

# Cidr blocks for the private subnets in the VPC (count = number of AZ's)
variable private_subnet_cidrs {
  type    = "list"
  default = []
}

# Cidr blocks for the private application subnets in the VPC (count = number of AZ's)
variable private_app_subnet_cidrs {
  type    = "list"
  default = []
}

# Cidr blocks for the private database subnets in the VPC (count = number of AZ's)
variable private_db_subnet_cidrs {
  type    = "list"
  default = []
}
