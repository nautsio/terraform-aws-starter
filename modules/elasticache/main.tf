/*
TODO: currently single node, this should be updated to allow cluster
configuration: see https://github.com/hashicorp/terraform/pull/8275
*/

resource "aws_security_group" "cache" {
  name        = "chache-sg"
  description = "Cache traffic"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "TCP"
    security_groups = ["${var.security_groups}"]
  }
}

resource "aws_elasticache_subnet_group" "cache-subnet-group" {
  name       = "cache-subnet-group"
  subnet_ids = ["${var.subnets}"]
}

resource "aws_elasticache_cluster" "cache" {
  cluster_id         = "cache-${var.name}"
  engine             = "redis"
  node_type          = "${var.node_type}"
  port               = 6379
  num_cache_nodes    = 1
  subnet_group_name  = "${aws_elasticache_subnet_group.cache-subnet-group.id}"
  security_group_ids = ["${aws_security_group.cache.id}"]
}
