resource "aws_security_group" "monitoring_instance" {
  name        = "monitoring_instance_sg"
  description = "Allow only inbound ssh traffic"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "TCP"
    security_groups = ["${var.ssh_security_groups}"]
  }

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "TCP"
    security_groups = ["${aws_security_group.monitoring_lb.id}"]
  }

  ingress {
    from_port       = 5601
    to_port         = 5601
    protocol        = "TCP"
    security_groups = ["${aws_security_group.monitoring_lb.id}"]
  }

  ingress {
    from_port       = 9090
    to_port         = 9090
    protocol        = "TCP"
    security_groups = ["${aws_security_group.monitoring_lb.id}"]
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

resource "aws_elb" "monitoring" {
  name            = "monitoring"
  subnets         = ["${var.vpc_subnets}"]
  security_groups = ["${aws_security_group.monitoring_lb.id}"]
  internal        = true

  listener {
    instance_port     = 3000
    instance_protocol = "HTTP"
    lb_port           = 3000
    lb_protocol       = "HTTP"
  }

  listener {
    instance_port     = 5601
    instance_protocol = "HTTP"
    lb_port           = 5601
    lb_protocol       = "HTTP"
  }

  listener {
    instance_port     = 9090
    instance_protocol = "HTTP"
    lb_port           = 9090
    lb_protocol       = "HTTP"
  }
}

resource "aws_security_group" "monitoring_lb" {
  name        = "monitoring_lb_sg"
  description = "Allow only inbound ssh traffic"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "TCP"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    from_port   = 5601
    to_port     = 5601
    protocol    = "TCP"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "TCP"
    cidr_blocks = ["${var.vpc_cidr}"]
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

resource "aws_launch_configuration" "monitoring" {
  name_prefix     = "monitoring-"
  image_id        = "${var.ami_id}"
  instance_type   = "${var.instance_type}"
  security_groups = ["${aws_security_group.monitoring_instance.id}", "${var.es_cluster_security_groups}"]
  key_name        = "${var.key_name}"
  user_data       = "${file("${path.module}/userdata.sh")}"

  ephemeral_block_device {
    device_name  = "/dev/xvdf"
    virtual_name = "ephemeral0"
  }

  ephemeral_block_device {
    device_name  = "/dev/xvdg"
    virtual_name = "ephemeral1"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "monitoring" {
  name = "monitoring"

  vpc_zone_identifier = ["${var.vpc_subnets}"]
  load_balancers      = ["${aws_elb.monitoring.name}"]

  desired_capacity          = "1"
  min_size                  = "1"
  max_size                  = "1"
  health_check_grace_period = "60"
  health_check_type         = "EC2"
  force_delete              = false
  launch_configuration      = "${aws_launch_configuration.monitoring.id}"
  wait_for_capacity_timeout = 0

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
    value               = "monitoring"
    propagate_at_launch = true
  }
}

resource "aws_route53_record" "monitoring_elb" {
  zone_id = "${var.zone_id}"
  name    = "monitoring"
  type    = "A"

  alias {
    name                   = "${aws_elb.monitoring.dns_name}"
    zone_id                = "${aws_elb.monitoring.zone_id}"
    evaluate_target_health = true
  }
}
