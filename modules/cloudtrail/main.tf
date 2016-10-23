# Capture current accound id
data "aws_caller_identity" "current" {}

data "template_file" "kms-cloudtrail-policy" {
  vars {
    account-id                 = "${data.aws_caller_identity.current.account_id}"
    list-accounts-arn          = "${jsonencode(formatlist("arn:aws:cloudtrail:*:%s:trail/*",var.accounts))}"
  }

  template = "${file("${path.module}/kms-cloudtrail-policy.json.tmpl")}"
}

data "template_file" "s3-bucket-cloudtrail-policy" {
  vars {
    s3-bucket-cloudtrail-arn = "${aws_s3_bucket.s3-bucket-cloudtrail.arn}"
    list-accounts-arn        = "${jsonencode(formatlist("arn:aws:s3:::%s-%s/AWSLogs/%s/*",var.s3-bucket-cloudtrail,data.aws_caller_identity.current.account_id,var.accounts))}"
  }

  template = "${file("${path.module}/s3-cloudtrail-policy.json.tmpl")}"
}

# creates bucket that saves data for max 3 years (compliant in finance)
# will transition files after 30 days to be infrequently accessed (30 is the minimum for STANDARD_IA).
# will transition files after 90 days to glacier.
# set force_destroy to true prior to removal
resource "aws_s3_bucket" "s3-bucket-cloudtrail" {
  bucket = "${var.s3-bucket-cloudtrail}-${data.aws_caller_identity.current.account_id}"
  acl    = "private"

  force_destroy = false

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true
    prefix  = ""

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 1098
    }

    noncurrent_version_transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_transition {
      days          = 90
      storage_class = "GLACIER"
    }

    noncurrent_version_expiration {
      days = 1098
    }
  }

  tags {
    Name      = "${var.s3-bucket-cloudtrail}"
    terraform = "true"
  }
}


resource "aws_s3_bucket_policy" "s3-bucket-cloudtrail-attach" {
  bucket = "${aws_s3_bucket.s3-bucket-cloudtrail.bucket}"
  policy = "${data.template_file.s3-bucket-cloudtrail-policy.rendered}"
}


resource "aws_kms_key" "kms-key-cloudtrail" {
  description         = "${var.kms-description-cloudtrail}"
  enable_key_rotation = true
  policy              = "${data.template_file.kms-cloudtrail-policy.rendered}"
}

resource "aws_kms_alias" "kms-alias-cloudtrail" {
  name          = "alias/${var.kms-description-cloudtrail}"
  target_key_id = "${aws_kms_key.kms-key-cloudtrail.key_id}"
}
