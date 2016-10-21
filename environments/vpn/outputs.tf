output "vpc_id" {
  value = "${aws_vpc.vpn.id}"
}

output "vpc_cidr_block" {
  value = "${aws_vpc.vpn.cidr_block}"
}

output "customer_gateway_configuration" {
  value = "${aws_vpn_connection.vpn.customer_gateway_configuration}"
}

output "customer_gateway_id" {
  value = "${aws_vpn_connection.vpn.customer_gateway_id}"
}

output "tunnel1_address" {
  value = "${aws_vpn_connection.vpn.tunnel1_address}"
}

output "tunnel1_preshared_key" {
  value = "${aws_vpn_connection.vpn.tunnel1_preshared_key}"
}

output "tunnel2_address" {
  value = "${aws_vpn_connection.vpn.tunnel2_address}"
}

output "tunnel2_preshared_key" {
  value = "${aws_vpn_connection.vpn.tunnel2_preshared_key}"
}

output "vpn_gateway_id" {
  value = "${aws_vpn_connection.vpn.vpn_gateway_id}"
}
