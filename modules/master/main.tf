resource "aws_security_group" "master_instance" {
  name        = "master_instance_sg"
  description = "Master instance: allow cluster traffic"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "TCP"
    security_groups = ["${var.bastion_sg_id}"]
  }

  # Allow all egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Mesos
  ingress {
    from_port       = 5050
    to_port         = 5051
    protocol        = "tcp"
    security_groups = ["${aws_security_group.master_lb.id}"]
  }

  # Marathon
  ingress {
    from_port       = 8090
    to_port         = 8090
    protocol        = "tcp"
    self            = true
    security_groups = ["${aws_security_group.master_lb.id}"]
  }

  # Vault
  ingress {
    from_port       = 8220
    to_port         = 8220
    protocol        = "tcp"
    self            = true
    security_groups = ["${aws_security_group.master_lb.id}"]
  }

  # Consul
  ingress {
    from_port       = 8500
    to_port         = 8500
    protocol        = "tcp"
    security_groups = ["${aws_security_group.master_lb.id}"]
  }

  # Mesos
  ingress {
    from_port = 31000
    to_port   = 32000
    protocol  = "tcp"
    self      = true
  }
}

resource "aws_ebs_volume" "master" {
  count = "${var.node_count}"

  availability_zone = "${element(var.azs, count.index)}"
  size              = 20
  type              = "gp2"
}

resource "aws_volume_attachment" "master" {
  count = "${var.node_count}"

  device_name = "/dev/xvdf"
  volume_id   = "${element(aws_ebs_volume.master.*.id, count.index)}"
  instance_id = "${element(aws_instance.master.*.id, count.index)}"
}

resource "aws_instance" "master" {
  count                   = "${var.node_count}"
  instance_type           = "${var.node_instance_type}"
  ami                     = "${var.ami_id}"
  subnet_id               = "${element(var.vpc_subnets, count.index)}"
  key_name                = "${var.key_name}"
  user_data               = "${file("${path.module}/userdata.sh")}"
  disable_api_termination = "${var.disable_api_termination}"

  vpc_security_group_ids = [
    "${aws_security_group.master_instance.id}",
    "${var.app_security_groups}",
  ]

  tags {
    name  = "${format("master-%d", count.index + 1)}"
    role  = "master"
    zk_id = "${count.index+1}"
    env   = "${var.env}"
  }
}

resource "aws_security_group" "master_lb" {
  name        = "master_lb_sg"
  description = "Master loadbalancer: allow management traffic"
  vpc_id      = "${var.vpc_id}"

  # Consul
  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "TCP"
    cidr_blocks = ["${var.vpc_cidr_blocks}"]
  }

  # Marathon
  ingress {
    from_port   = 8090
    to_port     = 8090
    protocol    = "TCP"
    cidr_blocks = ["${var.vpc_cidr_blocks}"]
  }

  # Mesos master
  ingress {
    from_port   = 5050
    to_port     = 5050
    protocol    = "TCP"
    cidr_blocks = ["${var.vpc_cidr_blocks}"]
  }

  # Mesos client
  ingress {
    from_port   = 5051
    to_port     = 5051
    protocol    = "TCP"
    cidr_blocks = ["${var.vpc_cidr_blocks}"]
  }

  # Vault
  ingress {
    from_port   = 8220
    to_port     = 8220
    protocol    = "TCP"
    cidr_blocks = ["${var.vpc_cidr_blocks}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "master" {
  name            = "master"
  subnets         = ["${var.vpc_subnets}"]
  security_groups = ["${aws_security_group.master_lb.id}"]
  instances       = ["${aws_instance.master.*.id}"]
  internal        = true

  # Consul
  listener {
    instance_port     = 8500
    instance_protocol = "http"
    lb_port           = 8500
    lb_protocol       = "http"
  }

  # Mesos master
  listener {
    instance_port     = 5050
    instance_protocol = "http"
    lb_port           = 5050
    lb_protocol       = "http"
  }

  # Mesos client
  listener {
    instance_port     = 5051
    instance_protocol = "http"
    lb_port           = 5051
    lb_protocol       = "http"
  }

  # Marathon
  listener {
    instance_port     = 8090
    instance_protocol = "http"
    lb_port           = 8090
    lb_protocol       = "http"
  }

  # Vault
  listener {
    instance_port     = 8220
    instance_protocol = "http"
    lb_port           = 8220
    lb_protocol       = "http"
  }
}

resource "aws_route53_record" "master_instance" {
  count   = "${var.node_count}"
  zone_id = "${var.zone_id}"
  name    = "${format("master-%d", count.index + 1)}"
  type    = "A"
  ttl     = 300
  records = ["${element(aws_instance.master.*.private_ip, count.index)}"]
}

resource "aws_route53_record" "master_elb" {
  zone_id = "${var.zone_id}"
  name    = "master"
  type    = "A"

  alias {
    name                   = "${aws_elb.master.dns_name}"
    zone_id                = "${aws_elb.master.zone_id}"
    evaluate_target_health = true
  }
}
