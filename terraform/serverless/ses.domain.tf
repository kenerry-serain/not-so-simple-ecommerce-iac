resource "aws_ses_domain_identity" "this" {
  domain = var.domain
}

resource "aws_route53_record" "ses_verification_record" {
  zone_id  = data.aws_route53_zone.this.zone_id
  name     = "_amazonses.${var.domain}"
  type     = "TXT"
  ttl      = "600"
  records  = [aws_ses_domain_identity.this.verification_token]
}

resource "aws_ses_domain_dkim" "this" {
  domain = aws_ses_domain_identity.this.domain
}

resource "aws_route53_record" "ses_dkim_record" {
  count    = 3
  zone_id  = data.aws_route53_zone.this.zone_id
  name     = "${aws_ses_domain_dkim.this.dkim_tokens[count.index]}._domainkey"
  type     = "CNAME"
  ttl      = "600"
  records  = ["${aws_ses_domain_dkim.this.dkim_tokens[count.index]}.dkim.amazonses.com"]
}


resource "aws_route53_record" "ses_dmark_record" {
  zone_id  = data.aws_route53_zone.this.zone_id
  name     = "_dmarc.${var.domain}"
  type     = "TXT"
  ttl      = "600"
  records  = ["v=DMARC1;p=none;"]
}

resource "aws_ses_domain_mail_from" "this" {
  domain           = aws_ses_domain_identity.this.domain
  mail_from_domain = "bounce.${aws_ses_domain_identity.this.domain}"
}

resource "aws_route53_record" "ses_domain_mail_from_mx" {
  zone_id  = data.aws_route53_zone.this.zone_id
  name     = aws_ses_domain_mail_from.this.mail_from_domain
  type     = "MX"
  ttl      = "600"
  records  = ["10 feedback-smtp.us-east-1.amazonses.com"]
}

resource "aws_route53_record" "ses_domain_mail_from_txt" {
  zone_id  = data.aws_route53_zone.this.zone_id
  name     = aws_ses_domain_mail_from.this.mail_from_domain
  type     = "TXT"
  ttl      = "600"
  records  = ["v=spf1 include:amazonses.com -all"]
}
