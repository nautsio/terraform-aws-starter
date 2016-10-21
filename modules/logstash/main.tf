resource "aws_security_group" "logstash_instance" {
  name        = "logstash_instance_sg"
  description = "Allow only inbound log/ssh traffic"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "TCP"
    security_groups = ["${var.vpc_security_groups}"]
  }

  # Beats
  ingress {
    from_port       = 5044
    to_port         = 5044
    protocol        = "TCP"
    security_groups = ["${aws_security_group.logstash_elb.id}"]
  }

  # Haproxy
  ingress {
    from_port       = 5144
    to_port         = 5144
    protocol        = "TCP"
    security_groups = ["${aws_security_group.logstash_elb.id}"]
  }

  # Docker
  ingress {
    from_port       = 5141
    to_port         = 5141
    protocol        = "TCP"
    security_groups = ["${aws_security_group.logstash_elb.id}"]
  }

  # Mesos
  ingress {
    from_port       = 5142
    to_port         = 5142
    protocol        = "TCP"
    security_groups = ["${aws_security_group.logstash_elb.id}"]
  }

  # Marathon
  ingress {
    from_port       = 5143
    to_port         = 5143
    protocol        = "TCP"
    security_groups = ["${aws_security_group.logstash_elb.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "logstash_elb" {
  name        = "logstash_elb"
  description = "Route incoming traffic to logstash server"
  vpc_id      = "${var.vpc_id}"

  # Beats
  ingress {
    from_port   = 5044
    to_port     = 5044
    protocol    = "TCP"
    cidr_blocks = ["${var.vpc_cidr_blocks}"]
  }

  # Haproxy
  ingress {
    from_port   = 5144
    to_port     = 5144
    protocol    = "TCP"
    cidr_blocks = ["${var.vpc_cidr_blocks}"]
  }

  # Docker
  ingress {
    from_port   = 5141
    to_port     = 5141
    protocol    = "TCP"
    cidr_blocks = ["${var.vpc_cidr_blocks}"]
  }

  # Mesos
  ingress {
    from_port   = 5142
    to_port     = 5142
    protocol    = "TCP"
    cidr_blocks = ["${var.vpc_cidr_blocks}"]
  }

  # Marathon
  ingress {
    from_port   = 5143
    to_port     = 5143
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

resource "aws_elb" "logstash" {
  name = "logstash"

  subnets         = ["${var.vpc_subnets}"]
  security_groups = ["${aws_security_group.logstash_elb.id}"]
  internal        = true

  listener {
    instance_port     = 22
    instance_protocol = "TCP"
    lb_port           = 22
    lb_protocol       = "TCP"
  }

  # Beats
  listener {
    instance_port     = 5044
    instance_protocol = "TCP"
    lb_port           = 5044
    lb_protocol       = "TCP"
  }

  # Haproxy
  listener {
    instance_port     = 5144
    instance_protocol = "TCP"
    lb_port           = 5144
    lb_protocol       = "TCP"
  }

  # Docker
  listener {
    instance_port     = 5141
    instance_protocol = "TCP"
    lb_port           = 5141
    lb_protocol       = "TCP"
  }

  # Mesos
  listener {
    instance_port     = 5142
    instance_protocol = "TCP"
    lb_port           = 5142
    lb_protocol       = "TCP"
  }

  # Marathon
  listener {
    instance_port     = 5143
    instance_protocol = "TCP"
    lb_port           = 5143
    lb_protocol       = "TCP"
  }
}

resource "aws_launch_configuration" "logstash" {
  name_prefix                 = "logstash-"
  image_id                    = "${var.image_id}"
  instance_type               = "${var.instance_type}"
  security_groups             = ["${aws_security_group.logstash_instance.id}"]
  key_name                    = "${var.key_name}"
  associate_public_ip_address = false

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "logstash" {
  name = "logstash"

  vpc_zone_identifier       = ["${var.vpc_subnets}"]
  load_balancers            = ["${aws_elb.logstash.name}"]
  desired_capacity          = "2"
  min_size                  = "1"
  max_size                  = "3"
  health_check_grace_period = "60"
  health_check_type         = "EC2"
  force_delete              = false
  wait_for_capacity_timeout = 0
  launch_configuration      = "${aws_launch_configuration.logstash.id}"

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "role"
    value               = "logstash"
    propagate_at_launch = true
  }
}

resource "aws_route53_record" "logstash_elb" {
  zone_id = "${var.zone_id}"
  name    = "logstash"
  type    = "A"

  alias {
    name                   = "${aws_elb.logstash.dns_name}"
    zone_id                = "${aws_elb.logstash.zone_id}"
    evaluate_target_health = true
  }
}
