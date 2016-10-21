# Default EC2 SSH key
resource "aws_key_pair" "mgmt_ssh" {
  key_name   = "mgmt_ssh"
  public_key = ""
}

# Bastion key_pair
resource "aws_key_pair" "bastion" {
  key_name   = "bastion"
  public_key = ""
}

module "vpc" {
  source = "../../modules/vpc"

  name = "${var.vpc_name}"
  cidr = "${var.vpc_cidr}"
}

module "public_subnet" {
  source = "../../modules/subnet"

  vpc_id = "${module.vpc.id}"
  name   = "public_subnet_${var.vpc_name}"
  cidrs  = "${var.public_subnet_cidrs}"
  azs    = "${var.azs}"
}

module "private_subnet" {
  source = "../../modules/subnet"

  vpc_id = "${module.vpc.id}"
  name   = "private_subnet_${var.vpc_name}"
  cidrs  = "${var.private_subnet_cidrs}"
  azs    = "${var.azs}"
}

module "nat" {
  source = "../../modules/nat"

  subnet_ids   = "${module.public_subnet.ids}"
  subnet_count = "${length(var.public_subnet_cidrs)}"
}

module "elasticsearch" {
  source = "../../modules/elasticsearch"

  vpc_id                       = "${module.vpc.id}"
  env                          = "${var.vpc_name}"
  vpc_subnets                  = "${module.private_subnet.ids}"
  key_name                     = "${aws_key_pair.mgmt_ssh.key_name}"
  zone_id                      = "${aws_route53_zone.env.zone_id}"
  ami_id                       = "${var.base_ami_id}"
  ssh_security_groups          = ["${module.bastion.security_group_id}"]
  es_interface_security_groups = ["${module.monitoring.security_group_id}", "${module.logstash.security_group_id}"]
  es_cluster_security_groups   = ["${module.monitoring.security_group_id}", "${module.logstash.security_group_id}"]
  es_mgmt_cidr_blocks          = ["${module.vpc.cidr_block}"]
}

module "monitoring" {
  source = "../../modules/monitoring"

  vpc_id                     = "${module.vpc.id}"
  vpc_cidr                   = "${module.vpc.cidr_block}"
  vpc_subnets                = "${module.private_subnet.ids}"
  key_name                   = "${aws_key_pair.mgmt_ssh.key_name}"
  zone_id                    = "${aws_route53_zone.env.zone_id}"
  ami_id                     = "${var.base_ami_id}"
  ssh_security_groups        = ["${module.bastion.security_group_id}"]
  es_cluster_security_groups = ["${module.elasticsearch.security_group_id}"]
}

module "bastion" {
  source = "../../modules/bastion"

  vpc_id      = "${module.vpc.id}"
  vpc_subnets = "${module.public_subnet.ids}"
  zone_id     = "${aws_route53_zone.aws_company_nl.zone_id}"
  key_name    = "${aws_key_pair.bastion.key_name}"
}

module "openvpn" {
  source = "../../modules/openvpn"

  vpc_id              = "${module.vpc.id}"
  vpc_subnets         = "${module.public_subnet.ids}"
  vpc_security_groups = ["${module.bastion.security_group_id}"]
  key_name            = "${aws_key_pair.mgmt_ssh.key_name}"
  zone_id             = "${aws_route53_zone.env.zone_id}"
}

module "jenkins" {
  source = "../../modules/jenkins"

  vpc_id              = "${module.vpc.id}"
  vpc_cidr            = "${module.vpc.cidr_block}"
  vpc_subnets         = "${module.private_subnet.ids}"
  vpc_security_groups = ["${module.bastion.security_group_id}"]
  key_name            = "${aws_key_pair.mgmt_ssh.key_name}"
  zone_id             = "${aws_route53_zone.env.zone_id}"
  ami_id              = "${var.base_ami_id}"
}

module "logstash" {
  source = "../../modules/logstash"

  vpc_id              = "${module.vpc.id}"
  key_name            = "${aws_key_pair.mgmt_ssh.key_name}"
  zone_id             = "${aws_route53_zone.env.zone_id}"
  image_id            = "${var.base_ami_id}"
  vpc_cidr_blocks     = ["${data.terraform_remote_state.acceptance.vpc_cidr}"]
  vpc_subnets         = "${module.private_subnet.ids}"
  vpc_security_groups = ["${module.bastion.security_group_id}"]
}

resource "aws_route" "public_igw_route" {
  count                  = "${length(var.public_subnet_cidrs)}"
  route_table_id         = "${element(module.public_subnet.route_table_ids, count.index)}"
  gateway_id             = "${module.vpc.igw}"
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "private_nat_route" {
  count                  = "${length(var.private_subnet_cidrs)}"
  route_table_id         = "${element(module.private_subnet.route_table_ids, count.index)}"
  nat_gateway_id         = "${element(module.nat.ids, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route53_zone" "env" {
  name   = "${coalesce(var.subdomain, var.vpc_name)}.${var.domain}"
  vpc_id = "${module.vpc.id}"
}
