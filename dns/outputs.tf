output "zone_name" {
  description = "Zone name from Cloudflare."
  value       = data.cloudflare_zone.this.name
}

output "zone_id" {
  description = "Cloudflare zone ID."
  value       = var.cloudflare_zone_id
}
