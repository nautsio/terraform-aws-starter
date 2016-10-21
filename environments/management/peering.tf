## Acceptance

# Add acceptance peer route to public subnet
resource "aws_route" "acc_vpc_peering_route_public_subnet" {
  count                     = "${length(var.public_subnet_cidrs)}"
  route_table_id            = "${element(module.public_subnet.route_table_ids, count.index)}"
  destination_cidr_block    = "${data.terraform_remote_state.acceptance.vpc_cidr}"
  vpc_peering_connection_id = "${data.terraform_remote_state.acceptance.mgmt_vpc_peering_connection_id}"
}

# Add acceptance peer route to private subnet
resource "aws_route" "acc_vpc_peering_route_private_subnet" {
  count                     = "${length(var.private_subnet_cidrs)}"
  route_table_id            = "${element(module.private_subnet.route_table_ids, count.index)}"
  destination_cidr_block    = "${data.terraform_remote_state.acceptance.vpc_cidr}"
  vpc_peering_connection_id = "${data.terraform_remote_state.acceptance.mgmt_vpc_peering_connection_id}"
}

## Services

resource "aws_vpc_peering_connection" "services_peering_connection" {
  vpc_id        = "${module.vpc.id}"
  peer_owner_id = "${var.management_account_id}"
  peer_vpc_id   = "${data.terraform_remote_state.services.vpc_id}"
  auto_accept   = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags {
    name = "VPC peering connection between management and services VPC"
  }
}

# Add services peer route to management public subnets
resource "aws_route" "mgmt_vpc_peering_route_services_public_subnet" {
  count                     = "${length(var.public_subnet_cidrs)}"
  route_table_id            = "${element(module.public_subnet.route_table_ids, count.index)}"
  destination_cidr_block    = "${data.terraform_remote_state.services.vpc_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.services_peering_connection.id}"
}

# Add management peer route to services public subnets
resource "aws_route" "services_vpc_peering_route_mgmt_private_subnet" {
  count                     = "${length(var.public_subnet_cidrs)}"
  route_table_id            = "${element(data.terraform_remote_state.services.public_subnet_route_table_ids, count.index)}"
  destination_cidr_block    = "${var.vpc_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.services_peering_connection.id}"
}
