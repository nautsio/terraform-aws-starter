# Create a CloudTrail S3 bucket
module "cloudtrail_storage" {
  source = "../../modules/cloudtrail"

  s3-bucket-cloudtrail       = "tf-cloudtrail"
  # AWS Accounts allowed to push logs to bucket. Try storing accounts in global variables.tf and reference them
  accounts                   = "${var.accounts_access_to_logging}"
  kms-description-cloudtrail = "tf-cloudtrail"
}

# Enable CloudTrail to log to bucket. Copy this to any other environment
resource "aws_cloudtrail" "cloudtrail_logging" {
  name                          = "tf-cloudtrail"
  s3_bucket_name                = "${module.cloudtrail_storage.s3-bucket-cloudtrail-name}"
  kms_key_id                    = "${module.cloudtrail_storage.kms-key-cloudtrail-arn}"
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = false

  tags {
    terraform = "true"
  }
}
