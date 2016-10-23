# use these outputs and reference remote state of the logging account so arns are always in sync.
output "cloudtrail-storage-arn" {
  value = "${module.cloudtrail_storage.s3-bucket-cloudtrail-arn}"
}
output "cloudtrail-storage-kms-arn" {
  value = "${module.cloudtrail_storage.kms-key-cloudtrail-arn}"
}
