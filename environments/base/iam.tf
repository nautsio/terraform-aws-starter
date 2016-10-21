# Production environment group
module "prd-group" {
  source = "../../modules/group"

  name    = "PrdAdminsGroup"
  role_id = "arn:aws:iam::{{ ACCOUNT_ID }}:role/{{ ROLE_NAME }}"
  members = ["ops"]
}

# Management environment group
module "mgmt-group" {
  source = "../../modules/group"

  name    = "MgmtAdminsGroup"
  role_id = "arn:aws:iam::{{ ACCOUNT_ID }}:role/{{ ROLE_NAME }}"
  members = ["ops"]
}

# Acceptance environment group
module "acc-group" {
  source = "../../modules/group"

  name    = "AccAdminsGroup"
  role_id = "arn:aws:iam::{{ ACCOUNT_ID }}:role/{{ ROLE_NAME }}"
  members = ["ops"]
}
