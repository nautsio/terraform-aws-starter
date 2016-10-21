resource "aws_security_group" "app_instance" {
  name        = "app_instance_sg"
  description = "App: allow only inbound http traffic from the loadbalancer"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "TCP"
    security_groups = ["${var.bastion_sg_id}"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "TCP"
    security_groups = ["${aws_security_group.app_lb.id}"]
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

resource "aws_launch_configuration" "app" {
  name_prefix                 = "app-"
  image_id                    = "${var.image_id}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  associate_public_ip_address = false
  iam_instance_profile        = "${aws_iam_instance_profile.app_profile.id}"
  user_data                   = "${file("${path.module}/userdata.sh")}"

  security_groups = [
    "${aws_security_group.app_instance.id}",
    "${var.app_security_groups}",
  ]

  root_block_device {
    volume_size = "${var.root_volume_size}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "app" {
  name = "app"

  vpc_zone_identifier = ["${var.vpc_subnets}"]
  load_balancers      = ["${aws_alb.app.name}"]

  desired_capacity          = "${var.desired_capacity}"
  min_size                  = "1"
  max_size                  = "${var.max_size}"
  health_check_grace_period = "60"
  health_check_type         = "EC2"
  force_delete              = false
  wait_for_capacity_timeout = 0
  launch_configuration      = "${aws_launch_configuration.app.id}"

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
    value               = "app"
    propagate_at_launch = true
  }

  tag {
    key                 = "env"
    value               = "${var.env}"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "app_lb" {
  name        = "app_lb_sg"
  description = "App: allow only HTTP traffic"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["", "", ""]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["", "", ""]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb" "app" {
  name            = "app"
  subnets         = ["${var.alb_public_subnets}"]
  security_groups = ["${aws_security_group.app_lb.id}"]
  internal        = false
}

resource "aws_alb_target_group" "app" {
  name     = "app"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {}
}

resource "aws_alb_listener" "app_80" {
  load_balancer_arn = "${aws_alb.app.arn}"
  port              = 80

  default_action {
    target_group_arn = "${aws_alb_target_group.app.arn}"
    type             = "forward"
  }
}

resource "aws_alb_listener" "app_443" {
  load_balancer_arn = "${aws_alb.app.arn}"
  port              = 443

  default_action {
    target_group_arn = "${aws_alb_target_group.app.arn}"
    type             = "forward"
  }
}

resource "aws_iam_instance_profile" "app_profile" {
  name  = "app_profile"
  roles = ["${aws_iam_role.role.name}"]
}

resource "aws_iam_role" "role" {
  name = "app"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
}
EOF
}

resource "aws_iam_role_policy" "app_policy" {
  name = "app_policy"
  role = "${aws_iam_role.role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
