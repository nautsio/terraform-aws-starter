output "vpc_id" {
  value = "${aws_security_group.jenkins_instance.vpc_id}"
}

output "security_group_id" {
  value = "${aws_security_group.jenkins_instance.id}"
}
