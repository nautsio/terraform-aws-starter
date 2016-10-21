resource "aws_security_group" "elasticsearch_instance" {
  name        = "elasticsearch_instance_sg"
  description = "Elasticsearch: allow HTTP and cluster traffic"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "TCP"
    security_groups = ["${var.ssh_security_groups}"]
  }

  ingress {
    from_port       = 9200
    to_port         = 9200
    protocol        = "TCP"
    security_groups = ["${aws_security_group.elasticsearch_lb.id}"]
  }

  ingress {
    from_port       = 9300
    to_port         = 9300
    protocol        = "TCP"
    security_groups = ["${var.es_cluster_security_groups}"]
    self            = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "elasticsearch" {
  count = "${var.node_count}"

  instance_type           = "${var.node_instance_type}"
  ami                     = "${var.ami_id}"
  subnet_id               = "${element(var.vpc_subnets, count.index)}"
  key_name                = "${var.key_name}"
  user_data               = "${file("${path.module}/userdata.sh")}"
  disable_api_termination = "${var.disable_api_termination}"

  vpc_security_group_ids = [
    "${aws_security_group.elasticsearch_instance.id}",
    "${var.app_security_groups}",
  ]

  ephemeral_block_device {
    device_name  = "/dev/xvdf"
    virtual_name = "ephemeral0"
  }

  ephemeral_block_device {
    device_name  = "/dev/xvdg"
    virtual_name = "ephemeral1"
  }

  tags {
    name = "${format("elasticsearch-%d", count.index + 1)}"
    role = "elasticsearch"
    env  = "${var.env}"
  }
}

resource "aws_security_group" "elasticsearch_lb" {
  name        = "elasticsearch_lb_sg"
  description = "Elasticsearch: allow only HTTP traffic"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port       = 9200
    to_port         = 9200
    protocol        = "TCP"
    security_groups = ["${var.es_interface_security_groups}"]
    cidr_blocks     = ["${var.es_mgmt_cidr_blocks}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "elasticsearch" {
  name            = "elasticsearch"
  subnets         = ["${var.vpc_subnets}"]
  security_groups = ["${aws_security_group.elasticsearch_lb.id}"]
  instances       = ["${aws_instance.elasticsearch.*.id}"]
  internal        = true

  listener {
    instance_port     = 9200
    instance_protocol = "TCP"
    lb_port           = 9200
    lb_protocol       = "TCP"
  }
}

resource "aws_route53_record" "elasticsearch_instance" {
  count   = "${var.node_count}"
  zone_id = "${var.zone_id}"
  name    = "${format("elasticsearch-%d", count.index + 1)}"
  type    = "A"
  ttl     = 300
  records = ["${element(aws_instance.elasticsearch.*.private_ip, count.index)}"]
}

resource "aws_route53_record" "elasticsearch_tcp" {
  zone_id = "${var.zone_id}"
  name    = "elasticsearch-tcp"
  type    = "A"
  ttl     = 5
  records = ["${aws_instance.elasticsearch.*.private_ip}"]
}

resource "aws_route53_record" "elasticsearch_elb" {
  zone_id = "${var.zone_id}"
  name    = "elasticsearch"
  type    = "A"

  alias {
    name                   = "${aws_elb.elasticsearch.dns_name}"
    zone_id                = "${aws_elb.elasticsearch.zone_id}"
    evaluate_target_health = true
  }
}
