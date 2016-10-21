data "terraform_remote_state" "management" {
  backend = "s3"

  config {
    bucket     = "terraform-state.management"
    region     = "{{ REGION }}"
    key        = "management.tfstate"
    encrypt    = 1
    kms_key_id = "arn:aws:kms:{{ REGION }}:{{ ACCOUNT_ID }}:key/{{ KEY_ID }}"
  }
}
