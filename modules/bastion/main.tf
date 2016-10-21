resource "aws_elb" "bastion" {
  name            = "bastion"
  subnets         = ["${var.vpc_subnets}"]
  security_groups = ["${aws_security_group.bastion.id}"]

  listener {
    instance_port     = 22
    instance_protocol = "TCP"
    lb_port           = 22
    lb_protocol       = "TCP"
  }
}

resource "aws_security_group" "bastion" {
  name        = "bastion_sg"
  description = "Allow only inbound ssh traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
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

  vpc_id = "${var.vpc_id}"
}

resource "aws_launch_configuration" "bastion" {
  name_prefix                 = "bastion-"
  image_id                    = "${var.image_id}"
  instance_type               = "${var.instance_type}"
  security_groups             = ["${aws_security_group.bastion.id}"]
  key_name                    = "${var.key_name}"
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "bastion" {
  name = "bastion"

  vpc_zone_identifier = ["${var.vpc_subnets}"]
  load_balancers      = ["${aws_elb.bastion.name}"]

  desired_capacity          = "1"
  min_size                  = "1"
  max_size                  = "1"
  health_check_grace_period = "60"
  health_check_type         = "EC2"
  force_delete              = false
  wait_for_capacity_timeout = 0
  launch_configuration      = "${aws_launch_configuration.bastion.id}"

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
    value               = "bastion"
    propagate_at_launch = true
  }
}

resource "aws_route53_record" "bastion_elb" {
  zone_id = "${var.zone_id}"
  name    = "bastion"
  type    = "A"

  alias {
    name                   = "${aws_elb.bastion.dns_name}"
    zone_id                = "${aws_elb.bastion.zone_id}"
    evaluate_target_health = true
  }
}
