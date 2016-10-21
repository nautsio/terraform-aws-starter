# Default EC2 SSH key
resource "aws_key_pair" "env_ssh" {
  key_name   = "env_ssh"
  public_key = "${var.public_key}"
}

module "vpc" {
  source = "../vpc"

  name = "${var.name}"
  cidr = "${var.cidr}"
}

module "public_subnet" {
  source = "../subnet"

  name   = "public_subnet_${var.name}"
  vpc_id = "${module.vpc.id}"
  cidrs  = "${var.public_subnet_cidrs}"
  azs    = "${var.azs}"
}

module "private_app_subnet" {
  source = "../subnet"

  name   = "private_app_subnet_${var.name}"
  vpc_id = "${module.vpc.id}"
  cidrs  = "${var.private_app_subnet_cidrs}"
  azs    = "${var.azs}"
}

module "private_db_subnet" {
  source = "../subnet"

  name   = "private_db_subnet_${var.name}"
  vpc_id = "${module.vpc.id}"
  cidrs  = "${var.private_db_subnet_cidrs}"
  azs    = "${var.azs}"
}

module "nat" {
  source = "../nat"

  subnet_ids   = "${module.public_subnet.ids}"
  subnet_count = "${length(var.public_subnet_cidrs)}"
}

module "rds" {
  source = "../rds"

  name                    = "${var.name}"
  subnets                 = ["${module.private_db_subnet.ids}"]
  security_groups         = ["${aws_security_group.postgresql.id}"]
  instance_class          = "${var.rds_instance_class}"
  username                = "${var.rds_username}"
  password                = "${var.rds_password}"
  instance_class          = "${var.rds_instance_class}"
  allocated_storage       = "${var.rds_allocated_storage}"
  publicly_accessible     = "${var.rds_publicly_accessible}"
  multi_az                = "${var.rds_multi_az}"
  zone_id                 = "${aws_route53_zone.env.zone_id}"
  skip_final_snapshot     = "${var.rds_skip_final_snapshot}"
  backup_retention_period = "${var.rds_backup_retention_period}"
}

module "elasticache" {
  source = "../elasticache"

  name            = "${var.name}"
  subnets         = ["${module.private_db_subnet.ids}"]
  security_groups = ["${module.app.security_group_id}"]
  node_type       = "${var.cache_node_type}"
  vpc_id          = "${module.vpc.id}"
}

module "elasticsearch" {
  source = "../elasticsearch"

  env                          = "${var.name}"
  vpc_id                       = "${module.vpc.id}"
  key_name                     = "${aws_key_pair.env_ssh.key_name}"
  zone_id                      = "${aws_route53_zone.env.zone_id}"
  ami_id                       = "${var.base_ami_id}"
  vpc_subnets                  = "${module.private_db_subnet.ids}"
  ssh_security_groups          = ["${var.bastion_sg_id}"]
  es_interface_security_groups = ["${module.app.security_group_id}"]
  es_cluster_security_groups   = ["${module.app.security_group_id}"]
  app_security_groups          = ["${aws_security_group.consul.id}", "${aws_security_group.elasticsearch.id}"]
  es_mgmt_cidr_blocks          = ["${var.mgmt_vpc_cidr}"]
}

module "app" {
  source = "../app"

  env              = "${var.name}"
  vpc_id           = "${module.vpc.id}"
  bastion_sg_id    = "${var.bastion_sg_id}"
  vpc_subnets      = "${module.private_app_subnet.ids}"
  vpc_cidr_blocks  = ["${var.mgmt_vpc_cidr}"]
  key_name         = "${aws_key_pair.env_ssh.key_name}"
  zone_id          = "${aws_route53_zone.env.zone_id}"
  desired_capacity = 1
  max_size         = 1
  image_id         = "${var.app_ami_id}"
  instance_type    = "${var.app_instance_type}"
  root_volume_size = "${var.app_root_volume_size}"

  app_security_groups = [
    "${aws_security_group.elasticsearch.id}",
    "${aws_security_group.cluster.id}",
    "${aws_security_group.consul.id}",
  ]

  alb_public_subnets = ["${module.public_subnet.ids}"]
}

module "master" {
  source = "../master"

  env             = "${var.name}"
  vpc_id          = "${module.vpc.id}"
  bastion_sg_id   = "${var.bastion_sg_id}"
  vpc_subnets     = "${module.private_app_subnet.ids}"
  key_name        = "${aws_key_pair.env_ssh.key_name}"
  zone_id         = "${aws_route53_zone.env.zone_id}"
  ami_id          = "${var.base_ami_id}"
  vpc_cidr_blocks = ["${var.mgmt_vpc_cidr}"]
  azs             = "${var.azs}"

  app_security_groups = [
    "${aws_security_group.cluster.id}",
    "${aws_security_group.consul.id}",
  ]
}

resource "aws_elb" "public" {
  name    = "public-elb-${var.name}"
  subnets = ["${module.public_subnet.ids}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

resource "aws_route" "public_igw_route" {
  count                  = "${length(var.public_subnet_cidrs)}"
  route_table_id         = "${element(module.public_subnet.route_table_ids, count.index)}"
  gateway_id             = "${module.vpc.igw}"
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "private_app_nat_route" {
  count                  = "${length(var.private_app_subnet_cidrs)}"
  route_table_id         = "${element(module.private_app_subnet.route_table_ids, count.index)}"
  nat_gateway_id         = "${element(module.nat.ids, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "private_db_nat_route" {
  count = "${length(var.private_db_subnet_cidrs)}"

  route_table_id         = "${element(module.private_db_subnet.route_table_ids, count.index)}"
  nat_gateway_id         = "${element(module.nat.ids, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route53_zone" "env" {
  name   = "${coalesce(var.subdomain, var.name)}.${var.domain}"
  vpc_id = "${module.vpc.id}"
}
