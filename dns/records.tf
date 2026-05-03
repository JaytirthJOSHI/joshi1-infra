# Synchronized from Cloudflare zone export (joshi1.com-3.txt, 2026-05-03).
# SOA/NS are omitted (managed by Cloudflare).

# --- A ---

resource "cloudflare_record" "a_ai" {
  zone_id = var.cloudflare_zone_id
  name    = "ai"
  type    = "A"
  content = "129.158.193.165"
  ttl     = 1
  proxied = true
  comment = "export cf-proxied:true"
}

resource "cloudflare_record" "a_api_fly" {
  zone_id = var.cloudflare_zone_id
  name    = "api.fly"
  type    = "A"
  content = "129.213.163.191"
  ttl     = 1
  proxied = false
  comment = "Joshi1-Oracle-VPS"
}

resource "cloudflare_record" "a_kuma" {
  zone_id = var.cloudflare_zone_id
  name    = "kuma"
  type    = "A"
  content = "129.158.239.198"
  ttl     = 1
  proxied = true
  comment = "export cf-proxied:true"
}

resource "cloudflare_record" "a_litellm" {
  zone_id = var.cloudflare_zone_id
  name    = "litellm"
  type    = "A"
  content = "129.158.193.165"
  ttl     = 1
  proxied = true
  comment = "export cf-proxied:true"
}

resource "cloudflare_record" "a_proxy" {
  zone_id = var.cloudflare_zone_id
  name    = "proxy"
  type    = "A"
  content = "129.158.193.165"
  ttl     = 1
  proxied = true
  comment = "export cf-proxied:true"
}

resource "cloudflare_record" "a_slack" {
  zone_id = var.cloudflare_zone_id
  name    = "slack"
  type    = "A"
  content = "158.101.97.168"
  ttl     = 1
  proxied = true
  comment = "export cf-proxied:true"
}

resource "cloudflare_record" "a_terry" {
  zone_id = var.cloudflare_zone_id
  name    = "terry"
  type    = "A"
  content = "100.82.31.76"
  ttl     = 1
  proxied = false
  comment = "export cf-proxied:false"
}

# --- CNAME ---

resource "cloudflare_record" "cname_agent" {
  zone_id = var.cloudflare_zone_id
  name    = "agent"
  type    = "CNAME"
  content = "dacb2209-0026-468e-8954-e59b8b94d33c.cfargotunnel.com"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "cname_aifood" {
  zone_id = var.cloudflare_zone_id
  name    = "aifood"
  type    = "CNAME"
  content = "idyllic-piroshki-341e14.netlify.app"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "cname_app" {
  zone_id = var.cloudflare_zone_id
  name    = "app"
  type    = "CNAME"
  content = "jaytirthjoshi.github.io"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "cname_fly" {
  zone_id = var.cloudflare_zone_id
  name    = "fly"
  type    = "CNAME"
  content = "fly-events-fun-ai.pages.dev"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "cname_fred" {
  zone_id = var.cloudflare_zone_id
  name    = "fred"
  type    = "CNAME"
  content = "fred-8ij.pages.dev"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "cname_guacclick" {
  zone_id = var.cloudflare_zone_id
  name    = "guacclick"
  type    = "CNAME"
  content = "hacktheclick.pages.dev"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "cname_meow" {
  zone_id = var.cloudflare_zone_id
  name    = "meow"
  type    = "CNAME"
  content = "jaytirthjoshi.github.io"
  ttl     = 1
  proxied = false
}

resource "cloudflare_record" "cname_n8n" {
  zone_id = var.cloudflare_zone_id
  name    = "n8n"
  type    = "CNAME"
  content = "c26aa12a-584d-4997-b842-f5333617c3ff.cfargotunnel.com"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "cname_nas" {
  zone_id = var.cloudflare_zone_id
  name    = "nas"
  type    = "CNAME"
  content = "c26aa12a-584d-4997-b842-f5333617c3ff.cfargotunnel.com"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "cname_panchang" {
  zone_id = var.cloudflare_zone_id
  name    = "panchang"
  type    = "CNAME"
  content = "mamtajoshi2329.github.io"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "cname_portainer" {
  zone_id = var.cloudflare_zone_id
  name    = "portainer"
  type    = "CNAME"
  content = "c26aa12a-584d-4997-b842-f5333617c3ff.cfargotunnel.com"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "cname_sig1_domainkey" {
  zone_id = var.cloudflare_zone_id
  name    = "sig1._domainkey"
  type    = "CNAME"
  content = "sig1.dkim.joshi1.com.at.icloudmailadmin.com"
  ttl     = 3600
  proxied = false
}

resource "cloudflare_record" "cname_uptime" {
  zone_id = var.cloudflare_zone_id
  name    = "uptime"
  type    = "CNAME"
  content = "c26aa12a-584d-4997-b842-f5333617c3ff.cfargotunnel.com"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "cname_vrishank" {
  zone_id = var.cloudflare_zone_id
  name    = "vrishank"
  type    = "CNAME"
  content = "vrishankjoshi.github.io"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "cname_www_aifood" {
  zone_id = var.cloudflare_zone_id
  name    = "www.aifood"
  type    = "CNAME"
  content = "idyllic-piroshki-341e14.netlify.app"
  ttl     = 1
  proxied = true
}

# --- MX ---

resource "cloudflare_record" "mx_mx01_icloud" {
  zone_id  = var.cloudflare_zone_id
  name     = "@"
  type     = "MX"
  priority = 10
  content  = "mx01.mail.icloud.com"
  ttl      = 3600
  proxied  = false
}

resource "cloudflare_record" "mx_mx02_icloud" {
  zone_id  = var.cloudflare_zone_id
  name     = "@"
  type     = "MX"
  priority = 10
  content  = "mx02.mail.icloud.com"
  ttl      = 3600
  proxied  = false
}

# --- TXT ---

resource "cloudflare_record" "txt_default_bimi" {
  zone_id = var.cloudflare_zone_id
  name    = "default._bimi"
  type    = "TXT"
  content = "v=BIMI1; l=https://joshi1.com/static/media/bimi-logo.svg;"
  ttl     = 1
  proxied = false
}

resource "cloudflare_record" "txt_dmarc" {
  zone_id = var.cloudflare_zone_id
  name    = "_dmarc"
  type    = "TXT"
  content = "v=DMARC1; p=reject; rua=mailto:dmarc_agg@vali.email; adkim=s; aspf=s"
  ttl     = 1
  proxied = false
}

resource "cloudflare_record" "txt_google_verification" {
  zone_id = var.cloudflare_zone_id
  name    = "@"
  type    = "TXT"
  content = "google-site-verification=4SucIlZJpKX7kUWjmddzp8Sl1VMnnujB7iJyBgpKx_c"
  ttl     = 1
  proxied = false
}

resource "cloudflare_record" "txt_apple_domain" {
  zone_id = var.cloudflare_zone_id
  name    = "@"
  type    = "TXT"
  content = "apple-domain=ORG5n7d22Y5szEoz"
  ttl     = 3600
  proxied = false
}

resource "cloudflare_record" "txt_spf" {
  zone_id = var.cloudflare_zone_id
  name    = "@"
  type    = "TXT"
  content = "v=spf1 include:icloud.com ~all"
  ttl     = 3600
  proxied = false
}

resource "cloudflare_record" "txt_netlify_challenge" {
  zone_id = var.cloudflare_zone_id
  name    = "netlify-challenge"
  type    = "TXT"
  content = "5b4017d070c1f3539c1b3227805ed2e3"
  ttl     = 1
  proxied = false
}

resource "cloudflare_record" "txt_token_dnswl" {
  zone_id = var.cloudflare_zone_id
  name    = "_token._dnswl"
  type    = "TXT"
  content = "vtk9kvigeh3je073k46wewg0e7on465m"
  ttl     = 1
  proxied = false
}

resource "cloudflare_record" "txt_vali_report_dmarc" {
  zone_id = var.cloudflare_zone_id
  name    = "vali._report._dmarc"
  type    = "TXT"
  content = "v=DMARC1"
  ttl     = 1
  proxied = false
}

resource "cloudflare_record" "txt_vercel_apex" {
  zone_id = var.cloudflare_zone_id
  name    = "_vercel"
  type    = "TXT"
  content = "vc-domain-verify=joshi1.com,fa4efdd16d9e6a5fb9dd,dc"
  ttl     = 600
  proxied = false
}

resource "cloudflare_record" "txt_vercel_subdomain" {
  zone_id = var.cloudflare_zone_id
  name    = "_vercel"
  type    = "TXT"
  content = "vc-domain-verify=jaytirth.joshi1.com,4b7fbc25068f821e394f,dc"
  ttl     = 600
  proxied = false
}
