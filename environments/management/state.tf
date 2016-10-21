data "terraform_remote_state" "acceptance" {
  backend = "s3"

  config {
    bucket     = "terraform-state.acceptance"
    region     = "{{ REGION }}"
    key        = "acceptance.tfstate"
    encrypt    = 1
    kms_key_id = "arn:aws:kms:{{ REGION }}:{{ ACCOUNT_ID }}:key/{{ KEY_ID }}"
  }
}

data "terraform_remote_state" "services" {
  backend = "s3"

  config {
    bucket     = "terraform-state.services"
    region     = "{{ REGION }}"
    key        = "services.tfstate"
    encrypt    = 1
    kms_key_id = "arn:aws:kms:{{ REGION }}:{{ ACCOUNT_ID }}:key/{{ KEY_ID }}"
  }
}
