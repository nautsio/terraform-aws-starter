resource "aws_iam_group" "group" {
  name = "${var.name}"
}

resource "aws_iam_group_policy" "group_policy" {
  name  = "${var.name}"
  group = "${aws_iam_group.group.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": "${var.role_id}"
    }
}
EOF
}

resource "aws_iam_group_membership" "group_members" {
  name = "${var.name}-group-membership"

  users = "${var.members}"
  group = "${aws_iam_group.group.name}"
}
