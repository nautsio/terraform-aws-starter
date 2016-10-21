output "vpc_id" {
  value = "${module.vpc.id}"
}

output "vpc_cidr" {
  value = "${module.vpc.cidr_block}"
}

output "bastion_vpc_id" {
  value = "${module.bastion.vpc_id}"
}

output "bastion_sg_id" {
  value = "${module.bastion.security_group_id}"
}

output "monitoring_sg_id" {
  value = "${module.monitoring.security_group_id}"
}

output "vpc_public_subnets" {
  value = ["${module.public_subnet.ids}"]
}

output "vpc_private_subnets" {
  value = ["${module.private_subnet.ids}"]
}

output "public_subnet_route_table_ids" {
  value = "${module.public_subnet.route_table_ids}"
}

output "private_subnet_route_table_ids" {
  value = "${module.private_subnet.route_table_ids}"
}

output "aws_company_nl_zone_id" {
  value = "${aws_route53_zone.aws_company_nl.zone_id}"
}
