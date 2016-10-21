resource "aws_security_group" "openvpn" {
  name        = "openvpn_sg"
  description = "OpenVPN traffic"

  ingress {
    from_port   = 943
    to_port     = 943
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "UDP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${var.vpc_id}"
}

resource "aws_eip" "openvpn" {
  instance = "${aws_instance.openvpn.id}"
  vpc      = true
}

resource "aws_instance" "openvpn" {
  instance_type               = "${var.node_instance_type}"
  ami                         = "${var.ami_id}"
  vpc_security_group_ids      = ["${aws_security_group.openvpn.id}", "${var.vpc_security_groups}"]
  associate_public_ip_address = true
  subnet_id                   = "${element(var.vpc_subnets, 0)}"
  key_name                    = "${var.key_name}"
  disable_api_termination     = "${var.disable_api_termination}"

  tags {
    role = "openvpn"
  }
}
