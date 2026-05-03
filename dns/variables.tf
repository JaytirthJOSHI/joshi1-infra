variable "cloudflare_api_token" {
  description = "Cloudflare API token (Zone:DNS:Edit, Zone:Zone:Read)."
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID for joshi1.com."
  type        = string
}

variable "domain" {
  description = "Apex domain (records use short names relative to this zone)."
  type        = string
  default     = "joshi1.com"
}
