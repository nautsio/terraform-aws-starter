resource "aws_security_group" "nexus" {
  name        = "nexus"
  description = "Route incoming traffic to Nexus"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "TCP"
    security_groups = ["${var.ssh_security_groups}"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["${var.allowed_cidr_blocks}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nexus" {
  instance_type               = "${var.instance_type}"
  ami                         = "${var.ami_id}"
  vpc_security_group_ids      = ["${aws_security_group.nexus.id}"]
  subnet_id                   = "${element(var.vpc_subnets, 0)}"
  key_name                    = "${var.key_name}"
  user_data                   = "${file("${path.module}/userdata.sh")}"
  availability_zone           = "${element(var.azs, 0)}"
  associate_public_ip_address = true

  tags {
    env  = "${var.env}"
    role = "nexus"
  }
}

resource "aws_ebs_volume" "nexus" {
  snapshot_id       = "${var.nexus_ebs_snapshot_id}"
  availability_zone = "${element(var.azs, 0)}"
  size              = 100
  type              = "gp2"
}

resource "aws_volume_attachment" "nexus" {
  device_name = "/dev/xvdf"
  volume_id   = "${aws_ebs_volume.nexus.id}"
  instance_id = "${aws_instance.nexus.id}"
}

resource "aws_route53_record" "nexus" {
  zone_id = "${var.zone_id}"
  name    = "nexus"
  type    = "CNAME"
  ttl     = 60
  records = ["${aws_instance.nexus.public_dns}"]
}
