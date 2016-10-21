resource "aws_security_group" "oracle" {
  name        = "sg_oracle"
  description = "Oracle database traffic"
  vpc_id      = "${module.vpc.id}"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "TCP"
    security_groups = ["${var.bastion_sg_id}"]
  }

  ingress {
    from_port = 1521
    to_port   = 1521
    protocol  = "TCP"

    security_groups = ["${module.app.security_group_id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
