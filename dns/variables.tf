variable "cloudflare_api_token" {
  description = "Cloudflare API token (Zone:DNS:Edit, Zone:Zone:Read, and Zone:Workers Routes:Edit for Worker routes)."
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID for joshi1.com (Dashboard → domain → Overview, right column)."
  type        = string
}

variable "domain" {
  description = "Apex domain managed by this stack."
  type        = string
  default     = "joshi1.com"
}

# --- Cloudflare Pages (CNAME targets from each project's Custom domains panel) ---

variable "pages_root_cname_target" {
  description = "CNAME target for the root / personal site (e.g. my-site.pages.dev)."
  type        = string
}

variable "pages_admin_cname_target" {
  description = "CNAME target for admin dashboard Pages project."
  type        = string
}

variable "pages_net_cname_target" {
  description = "CNAME target for net.* Pages project (placeholder until the project exists)."
  type        = string
}

# --- Workers (script names as shown in Workers & Pages → Workers) ---

variable "firefly_worker_script_name" {
  description = "Deployed Worker script name for firefly subdomain."
  type        = string
}

variable "go_worker_script_name" {
  description = "Deployed Worker script name for go subdomain (e.g. Sink fork)."
  type        = string
}
