# Apex → Cloudflare Pages (personal site)
resource "cloudflare_record" "root_pages" {
  zone_id = var.cloudflare_zone_id
  name    = "@"
  type    = "CNAME"
  content = var.pages_root_cname_target
  proxied = true
  ttl     = 1
  comment = "Root site (Cloudflare Pages)"
}

# Subdomains → Cloudflare Pages
resource "cloudflare_record" "admin_pages" {
  zone_id = var.cloudflare_zone_id
  name    = "admin"
  type    = "CNAME"
  content = var.pages_admin_cname_target
  proxied = true
  ttl     = 1
  comment = "Admin dashboard (Cloudflare Pages)"
}

resource "cloudflare_record" "net_pages" {
  zone_id = var.cloudflare_zone_id
  name    = "net"
  type    = "CNAME"
  content = var.pages_net_cname_target
  proxied = true
  ttl     = 1
  comment = "Future Pages project"
}

# Proxied IPv6 placeholder so Worker routes can terminate HTTPS for the hostname.
# Traffic is handled by cloudflare_workers_route resources in workers.tf.
# Alternative: use cloudflare_workers_domain (requires CLOUDFLARE_ACCOUNT_ID) — see README.
resource "cloudflare_record" "firefly_worker_dns" {
  zone_id = var.cloudflare_zone_id
  name    = "firefly"
  type    = "AAAA"
  content = "100::"
  proxied = true
  ttl     = 1
  comment = "Worker route target (firefly)"
}

resource "cloudflare_record" "go_worker_dns" {
  zone_id = var.cloudflare_zone_id
  name    = "go"
  type    = "AAAA"
  content = "100::"
  proxied = true
  ttl     = 1
  comment = "Worker route target (go)"
}
