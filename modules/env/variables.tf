variable "name" {}

variable "domain" {
  default = "aws.company.internal"
}

variable "subdomain" {}

variable "cidr" {}

variable "rds_username" {}

variable "rds_password" {}

variable "rds_multi_az" {}

variable "rds_publicly_accessible" {}

variable "rds_skip_final_snapshot" {}

variable "rds_backup_retention_period" {}

variable "base_ami_id" {}

variable "app_ami_id" {}

variable "public_key" {}

variable "bastion_sg_id" {}

variable "monitoring_sg_id" {}

variable "mgmt_vpc_cidr" {}

variable "rds_instance_class" {}

variable "rds_allocated_storage" {}

variable "cache_node_type" {
  default = "cache.t2.micro"
}

variable "app_instance_type" {}

variable "app_root_volume_size" {}

variable "azs" {
  type = "list"
}

variable "public_subnet_cidrs" {
  type = "list"
}

variable "private_app_subnet_cidrs" {
  type = "list"
}

variable "private_db_subnet_cidrs" {
  type = "list"
}
