output "vpc_id" {
  value = "${aws_security_group.nexus.vpc_id}"
}

output "security_group_id" {
  value = "${aws_security_group.nexus.id}"
}
