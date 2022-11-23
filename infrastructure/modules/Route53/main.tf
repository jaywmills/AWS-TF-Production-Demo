resource "tls_private_key" "ssl_key" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "ssl_cert" {
  # key_algorithm   = "RSA"
  private_key_pem = tls_private_key.ssl_key.private_key_pem

  subject {
    common_name = var.domain_name
  }

  validity_period_hours = 12

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "acm_ssl_cert" {
  private_key      = tls_private_key.ssl_key.private_key_pem
  certificate_body = tls_self_signed_cert.ssl_cert.cert_pem
}

# Route53 Private Hosted Zone
resource "aws_route53_zone" "internal_webserver" {
  name = "webserver.com"

  vpc {
    vpc_id = var.vpc_id
  }
}

# Route53 CNAME Record
resource "aws_route53_record" "cname_route53_record" {
  zone_id = aws_route53_zone.internal_webserver.zone_id
  name    = "www.webserver.com"
  type    = "CNAME"
  ttl     = "60"
  records = [var.records]
}