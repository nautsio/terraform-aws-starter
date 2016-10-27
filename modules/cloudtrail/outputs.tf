output "s3-bucket-cloudtrail-name" {
  value = "${aws_s3_bucket.s3-bucket-cloudtrail.id}"
}

output "s3-bucket-cloudtrail-arn" {
  value = "${aws_s3_bucket.s3-bucket-cloudtrail.arn}"
}

output "kms-key-cloudtrail-id" {
  value = "${aws_kms_key.kms-key-cloudtrail.key_id}"
}

output "kms-key-cloudtrail-arn" {
  value = "${aws_kms_key.kms-key-cloudtrail.arn}"
}
