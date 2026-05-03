resource "cloudflare_workers_route" "firefly" {
  zone_id     = var.cloudflare_zone_id
  pattern     = "firefly.${var.domain}/*"
  script_name = var.firefly_worker_script_name
}

resource "cloudflare_workers_route" "go" {
  zone_id     = var.cloudflare_zone_id
  pattern     = "go.${var.domain}/*"
  script_name = var.go_worker_script_name
}
