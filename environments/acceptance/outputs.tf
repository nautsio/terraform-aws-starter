output "vpc_id" {
  value = "${module.env.vpc_id}"
}

output "vpc_cidr" {
  value = "${module.env.vpc_cidr}"
}

output "mgmt_vpc_peering_connection_id" {
  value = "${aws_vpc_peering_connection.mgmt_peering_connection.id}"
}

output "app_alb_dns_name" {
  value = "${module.env.app_alb_dns_name}"
}

output "app_alb_zone_id" {
  value = "${module.env.app_alb_zone_id}"
}
