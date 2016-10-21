resource "aws_route53_zone" "aws_company_nl" {
  name = "aws.company.nl"
}

resource "aws_route53_record" "public_acceptance_dns" {
  zone_id = "${aws_route53_zone.aws_company_nl.id}"
  name    = ""
  type    = "A"

  alias {
    name                   = "${data.terraform_remote_state.acceptance.app_alb_dns_name}"
    zone_id                = "${data.terraform_remote_state.acceptance.app_alb_zone_id}"
    evaluate_target_health = true
  }
}
