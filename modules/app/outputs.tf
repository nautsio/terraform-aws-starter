output "security_group_id" {
  value = "${aws_security_group.app_instance.id}"
}

output "alb_dns_name" {
  value = "${aws_alb.app.dns_name}"
}

output "alb_zone_id" {
  value = "${aws_alb.app.zone_id}"
}
