variable "name" {
}

variable "zone_id" {
}

variable "username" {
}

variable "password" {
}

variable "subnets" {
  type = "list"
}

variable "security_groups" {
  type = "list"
}

variable "engine" {
  default = "postgres"
}

variable "engine_version" {
  default = "9.5.2"
}

variable "instance_class" {
  default = "db.t2.micro"
}

variable "allocated_storage" {
  # 10 gigabyte
  default = 10
}

variable "backup_retention_period" {
  # 1 day
  default = 1
}

variable "skip_final_snapshot" {
  default = true
}

variable "maintenance_window" {
  default = "Sun:00:00-Sun:03:00"
}

variable "multi_az" {
  default = false
}

variable "storage_encrypted" {
  default = true
}

variable "publicly_accessible" {
  default = false
}
