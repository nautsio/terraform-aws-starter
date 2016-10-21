resource "aws_security_group" "postgresql" {
  name        = "sg_postgresql"
  description = "Postgresql database traffic"
  vpc_id      = "${module.vpc.id}"

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "TCP"
    security_groups = ["${module.app.security_group_id}", "${module.master.security_group_id}"]
  }
}
