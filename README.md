# joshi1-infra

**DNS-as-code reference** for **joshi1.com**: Terraform mirrors what’s in Cloudflare (`dns/records.tf`), synced from zone export **`joshi1.com-3.txt`** (2026-05-03). SOA/NS are omitted (Cloudflare-managed).

**GitHub Actions Terraform workflows are intentionally removed** — nothing runs on push/PR. Live DNS stays in Cloudflare; edit there or in this repo and apply by hand when you’re ready.

## Layout

| Path | Purpose |
|------|---------|
| `dns/` | Terraform root (`records.tf` has **34** `cloudflare_record` resources) |
| `dns/backend.tf.example` | Optional Terraform Cloud state (copy to `backend.tf`) |
| `scripts/gen-imports.py` | Prints `terraform import` lines against the live zone (needs API token) |
| `scripts/list-dns-record-ids.sh` | Lists record IDs (jq + curl) |

## If you use Terraform later

1. `cd dns` → `cp terraform.tfvars.example terraform.tfvars` → add token + zone ID.  
2. **Do not `apply` on an empty state** — import existing records first (`scripts/gen-imports.py`).  
3. Optional remote state: copy `backend.tf.example` → `backend.tf`, `terraform login`, `terraform init`.

Do not commit `terraform.tfvars` or API tokens.
