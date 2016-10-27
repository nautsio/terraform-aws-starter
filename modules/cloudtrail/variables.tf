variable "s3-bucket-cloudtrail" {
  description = "Name of S3 Bucket in which to store Cloudtrail logs"
}

variable "accounts" {
  type        = "list"
  description = "List of Account IDs"
}

variable "kms-description-cloudtrail" {
  description = "Description of the KMS key used to store Cloudtrail logs"
}
