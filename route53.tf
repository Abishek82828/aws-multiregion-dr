locals {
  primary_api_domain   = replace(module.api_primary.api_endpoint, "https://", "")
  secondary_api_domain = replace(module.api_secondary.api_endpoint, "https://", "")
  failover_record_name = "api.dr.${var.root_domain}"
}

resource "aws_route53_zone" "dr" {
  provider = aws.primary
  name     = "dr.${var.root_domain}"
}

resource "aws_route53_health_check" "primary_api" {
  provider = aws.primary

  fqdn              = local.primary_api_domain
  port              = 443
  type              = "HTTPS"
  resource_path     = "/health"
  failure_threshold = 3
  request_interval  = 30

  tags = {
    Name = "${var.project_name}-primary-health"
  }
}

resource "aws_route53_record" "api_primary" {
  provider = aws.primary

  zone_id = aws_route53_zone.dr.zone_id
  name    = local.failover_record_name
  type    = "CNAME"
  ttl     = 60
  records = [local.primary_api_domain]

  set_identifier = "primary"
  failover_routing_policy {
    type = "PRIMARY"
  }
  health_check_id = aws_route53_health_check.primary_api.id
}

resource "aws_route53_record" "api_secondary" {
  provider = aws.primary

  zone_id = aws_route53_zone.dr.zone_id
  name    = local.failover_record_name
  type    = "CNAME"
  ttl     = 60
  records = [local.secondary_api_domain]

  set_identifier = "secondary"
  failover_routing_policy {
    type = "SECONDARY"
  }
}
