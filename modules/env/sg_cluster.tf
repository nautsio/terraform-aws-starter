resource "aws_security_group" "cluster" {
  name        = "sg_cluster"
  description = "Allow cluster traffic"
  vpc_id      = "${module.vpc.id}"

  # ZooKeeper
  ingress {
    from_port = 2181
    to_port   = 2181
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 2888
    to_port   = 2888
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 3888
    to_port   = 3888
    protocol  = "tcp"
    self      = true
  }

  # Mesos
  ingress {
    from_port = 5050
    to_port   = 5051
    protocol  = "tcp"
    self      = true

    cidr_blocks = ["${var.mgmt_vpc_cidr}"]
  }

  ingress {
    from_port       = 30000
    to_port         = 32000
    protocol        = "tcp"
    self            = true
    security_groups = ["${var.monitoring_sg_id}"]
  }

  # Vault
  ingress {
    from_port = 8220
    to_port   = 8220
    protocol  = "tcp"
    self      = true
  }
}
