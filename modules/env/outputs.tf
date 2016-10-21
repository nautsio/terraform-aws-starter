output "vpc_id" {
  value = "${module.vpc.id}"
}

output "vpc_cidr" {
  value = "${module.vpc.cidr_block}"
}

output "vpc_main_route_table_id" {
  value = "${module.vpc.main_route_table_id}"
}

output "vpc_route53_zone_id" {
  value = "${aws_route53_zone.env.zone_id}"
}

output "public_subnet_route_table_ids" {
  value = "${module.public_subnet.route_table_ids}"
}

output "private_app_subnet_route_table_ids" {
  value = "${module.private_app_subnet.route_table_ids}"
}

output "private_db_subnet_route_table_ids" {
  value = "${module.private_db_subnet.route_table_ids}"
}

output "app_alb_dns_name" {
  value = "${module.app.alb_dns_name}"
}

output "app_alb_zone_id" {
  value = "${module.app.alb_zone_id}"
}
