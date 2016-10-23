resource "aws_key_pair" "services_ssh" {
  key_name   = "services_ssh"
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

module "nexus" {
  source = "../../modules/nexus"

  vpc_id              = "${module.vpc.id}"
  env                 = "${var.vpc_name}"
  vpc_subnets         = "${module.public_subnet.ids}"
  key_name            = "${aws_key_pair.services_ssh.key_name}"
  zone_id             = "${data.terraform_remote_state.management.aws_company_nl_zone_id}"
  ami_id              = "${var.base_ami_id}"
  allowed_cidr_blocks = ["", "", ""]
  ssh_security_groups = ["${data.terraform_remote_state.management.bastion_sg_id}"]
  azs                 = "${var.azs}"
}

resource "aws_route" "public_igw_route" {
  count                  = "${length(var.public_subnet_cidrs)}"
  route_table_id         = "${element(module.public_subnet.route_table_ids, count.index)}"
  gateway_id             = "${module.vpc.igw}"
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route53_zone" "env" {
  name   = "${coalesce(var.subdomain, var.vpc_name)}.${var.domain}"
  vpc_id = "${module.vpc.id}"
}
