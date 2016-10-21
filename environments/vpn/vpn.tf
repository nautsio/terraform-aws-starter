resource "aws_vpc" "vpn" {
  cidr_block = "${var.vpc_cidr}"

  tags {
    Environment = "${var.vpc_name}"
  }
}

resource "aws_vpn_gateway" "vpn_gateway" {
  vpc_id = "${aws_vpc.vpn.id}"
}

resource "aws_customer_gateway" "vpn" {
  bgp_asn    = "${var.bgp_asn}"
  ip_address = "${var.ip_address}"
  type       = "${var.vpn_type}"
}

resource "aws_vpn_connection" "vpn" {
  vpn_gateway_id      = "${aws_vpn_gateway.vpn_gateway.id}"
  customer_gateway_id = "${aws_customer_gateway.vpn.id}"
  type                = "${var.vpn_type}"
  static_routes_only  = false
}
