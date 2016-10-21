resource "aws_security_group" "elasticsearch" {
  name        = "sg_elasticsearch"
  description = "Allow elasticsearch traffic"
  vpc_id      = "${module.vpc.id}"

  ingress {
    from_port = 9200
    to_port   = 9200
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 9300
    to_port   = 9300
    protocol  = "tcp"
    self      = true
  }
}
