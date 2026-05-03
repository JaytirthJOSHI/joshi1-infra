provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

data "cloudflare_zone" "this" {
  zone_id = var.cloudflare_zone_id
}
