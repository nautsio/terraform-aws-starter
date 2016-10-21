# Peer with management vpc
resource "aws_vpc_peering_connection" "mgmt_peering_connection" {
  vpc_id        = "${module.env.vpc_id}"
  peer_owner_id = "${var.management_account_id}"
  peer_vpc_id   = "${data.terraform_remote_state.management.vpc_id}"

  accepter {
    allow_remote_vpc_dns_resolution = true
  }
}

# Add mgmt peer route to public subnet
resource "aws_route" "mgmt_vpc_peering_route_public_subnet" {
  count                     = "${length(var.public_subnet_cidrs)}"
  route_table_id            = "${element(module.env.public_subnet_route_table_ids, count.index)}"
  destination_cidr_block    = "${data.terraform_remote_state.management.vpc_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.mgmt_peering_connection.id}"
}

# Add mgmt peer route to private app subnet
resource "aws_route" "mgmt_vpc_peering_route_private_app_subnet" {
  count                     = "${length(var.private_app_subnet_cidrs)}"
  route_table_id            = "${element(module.env.private_app_subnet_route_table_ids, count.index)}"
  destination_cidr_block    = "${data.terraform_remote_state.management.vpc_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.mgmt_peering_connection.id}"
}

# Add mgmt peer route to private db subnet
resource "aws_route" "mgmt_vpc_peering_route_private_db_subnet" {
  count                     = "${length(var.private_db_subnet_cidrs)}"
  route_table_id            = "${element(module.env.private_db_subnet_route_table_ids, count.index)}"
  destination_cidr_block    = "${data.terraform_remote_state.management.vpc_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.mgmt_peering_connection.id}"
}
