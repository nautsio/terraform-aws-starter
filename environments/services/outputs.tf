output "vpc_id" {
  value = "${module.vpc.id}"
}

output "vpc_cidr" {
  value = "${module.vpc.cidr_block}"
}

output "vpc_public_subnets" {
  value = [
    "${module.public_subnet.ids}",
  ]
}

output "public_subnet_route_table_ids" {
  value = "${module.public_subnet.route_table_ids}"
}
