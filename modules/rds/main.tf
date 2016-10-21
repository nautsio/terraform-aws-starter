resource "aws_db_subnet_group" "rds-subnet-group" {
  name       = "rds-subnet-group"
  subnet_ids = ["${var.subnets}"]
}

resource "aws_db_instance" "postgresql" {
  allocated_storage         = "${var.allocated_storage}"
  engine                    = "${var.engine}"
  engine_version            = "${var.engine_version}"
  instance_class            = "${var.instance_class}"
  name                      = "${var.name}"
  username                  = "${var.username}"
  password                  = "${var.password}"
  db_subnet_group_name      = "${aws_db_subnet_group.rds-subnet-group.id}"
  vpc_security_group_ids    = ["${var.security_groups}"]
  publicly_accessible       = "${var.publicly_accessible}"
  multi_az                  = "${var.multi_az}"
  backup_retention_period   = "${var.backup_retention_period}"
  maintenance_window        = "${var.maintenance_window}"
  skip_final_snapshot       = "${var.skip_final_snapshot}"
  storage_encrypted         = "${var.storage_encrypted}"
  storage_type              = "gp2"
  final_snapshot_identifier = "final-snapshot"
}

resource "aws_route53_record" "rds" {
  zone_id = "${var.zone_id}"
  name    = "db"
  type    = "CNAME"
  ttl     = 5
  records = ["${replace(aws_db_instance.postgresql.endpoint, "/:.*/", "")}"]
}
