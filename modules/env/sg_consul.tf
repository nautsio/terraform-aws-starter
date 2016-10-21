resource "aws_security_group" "consul" {
  name        = "sg_consul"
  description = "Allow consul traffic"
  vpc_id      = "${module.vpc.id}"

  ingress {
    from_port = 8500
    to_port   = 8500
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 1053
    to_port   = 1053
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 1053
    to_port   = 1053
    protocol  = "udp"
    self      = true
  }

  ingress {
    from_port = 8306
    to_port   = 8306
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 8306
    to_port   = 8306
    protocol  = "udp"
    self      = true
  }

  ingress {
    from_port = 8303
    to_port   = 8303
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 8303
    to_port   = 8303
    protocol  = "udp"
    self      = true
  }

  ingress {
    from_port = 8401
    to_port   = 8401
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 8307
    to_port   = 8307
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 8307
    to_port   = 8307
    protocol  = "udp"
    self      = true
  }
}
