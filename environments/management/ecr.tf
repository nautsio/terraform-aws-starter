resource "aws_ecr_repository" "repo" {
  count = "${length(var.ecr_repositories)}"
  name  = "company/${element(var.ecr_repositories, count.index)}"
}

resource "aws_ecr_repository_policy" "repository_policy" {
  count = "${length(var.ecr_repositories)}"

  repository = "${element(aws_ecr_repository.repo.*.name, count.index)}"

  policy = <<EOF
{
	"Version": "2008-10-17",
	"Statement": [{
		"Sid": "PullECRImages",
		"Effect": "Allow",
		"Principal": {
			"AWS": ["arn:aws:iam::{{ ACCOUNT_ID }}:root", "arn:aws:iam::{{ ACCOUNT_ID }}:root"]
		},
		"Action": ["ecr:BatchGetImage", "ecr:ListImages", "ecr:GetDownloadUrlForLayer", "ecr:BatchCheckLayerAvailability"]
	}]
}
EOF
}
