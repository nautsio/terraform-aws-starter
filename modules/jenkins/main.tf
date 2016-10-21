resource "aws_security_group" "jenkins_elb" {
  name        = "jenkins_elb"
  description = "Allow only inbound http(s) traffic"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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

resource "aws_elb" "jenkins" {
  name            = "jenkins"
  subnets         = ["${var.vpc_subnets}"]
  security_groups = ["${aws_security_group.jenkins_elb.id}"]
  internal        = true

  listener {
    instance_port     = 8080
    instance_protocol = "TCP"
    lb_port           = 80
    lb_protocol       = "TCP"
  }

  listener {
    instance_port     = 443
    instance_protocol = "TCP"
    lb_port           = 443
    lb_protocol       = "TCP"
  }
}

resource "aws_security_group" "jenkins_instance" {
  name        = "jenkins_sg"
  description = "Allow only inbound http(s) traffic from the loadbalancer"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "TCP"
    security_groups = ["${var.vpc_security_groups}"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "TCP"
    security_groups = ["${aws_security_group.jenkins_elb.id}"]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "TCP"
    security_groups = ["${aws_security_group.jenkins_elb.id}"]
  }

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "TCP"
    security_groups = ["${aws_security_group.jenkins_elb.id}"]
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

resource "aws_launch_configuration" "jenkins" {
  name_prefix     = "jenkins-"
  image_id        = "${var.ami_id}"
  instance_type   = "${var.instance_type}"
  security_groups = ["${aws_security_group.jenkins_instance.id}"]
  key_name        = "${var.key_name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "jenkins" {
  name = "jenkins"

  vpc_zone_identifier = ["${var.vpc_subnets}"]
  load_balancers      = ["${aws_elb.jenkins.name}"]

  desired_capacity          = "1"
  min_size                  = "1"
  max_size                  = "1"
  health_check_grace_period = "60"
  health_check_type         = "EC2"
  force_delete              = false
  wait_for_capacity_timeout = 0
  launch_configuration      = "${aws_launch_configuration.jenkins.id}"

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
    value               = "jenkins"
    propagate_at_launch = true
  }
}

resource "aws_route53_record" "jenkins_elb" {
  zone_id = "${var.zone_id}"
  name    = "jenkins"
  type    = "A"

  alias {
    name                   = "${aws_elb.jenkins.dns_name}"
    zone_id                = "${aws_elb.jenkins.zone_id}"
    evaluate_target_health = true
  }
}
