resource "aws_key_pair" "services_ssh" {
  key_name   = "services_ssh"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8XsEjh7y7RrluiN7QYzBleHfXnxJfnhqwV0n5deDYaLYWPlDTg0AiL3nuqLUG0ED7Alb+rrMqxGO0YkYqrEFD3I2AfiSfWVuFIMvHQxyK0L8hmsN4lnYhsLOnDWS81bjkKcKG84s+fk5u+FJDsdeRH6rAQaaHE2JHTLxoPG8e+YVeBG8CMudt7srVkDGi2VKQv2SVwgxocrPmmYW1F9ThyN77oo0drWolJcsVSRvGJohaTOtRS0KN6mIwgfyjNKGmgJyCRR6DugNYyZ49tT5alZZuLfSjSVleh62Zok/PGwIohQnOoU034y01v9zEB4ZBlJRT52TFVntlpTn+u37v"
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
