output "zone_name" {
  description = "Zone name from Cloudflare."
  value       = data.cloudflare_zone.this.name
}

output "zone_id" {
  description = "Cloudflare zone ID."
  value       = var.cloudflare_zone_id
}

output "pages_hostnames" {
  description = "Hostnames served via Cloudflare Pages (CNAME)."
  value = [
    var.domain,
    "admin.${var.domain}",
    "net.${var.domain}",
  ]
}

output "worker_route_patterns" {
  description = "Worker route patterns managed by Terraform."
  value = [
    cloudflare_workers_route.firefly.pattern,
    cloudflare_workers_route.go.pattern,
  ]
}
