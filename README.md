# joshi1-infra

DNS for **joshi1.com** as code: Terraform (Cloudflare provider), GitHub Actions (plan on PR, apply on `main`), Terraform Cloud for remote state.

## Layout

| Path | Purpose |
|------|---------|
| `dns/main.tf` | Provider + zone data source |
| `dns/variables.tf` | API token, zone ID |
| `dns/records.tf` | All DNS records (synced from your Cloudflare export) |
| `dns/outputs.tf` | Zone outputs |
| `dns/backend.tf.example` | Terraform Cloud backend (generated in CI) |
| `.github/workflows/terraform.yml` | CI |

`dns/records.tf` matches the BIND-style export **`joshi1.com-3.txt`** (2026-05-03). SOA/NS are omitted (Cloudflare-managed). **Worker routes** are not in that export; manage them separately or add resources later.

## First deploy — do not `apply` blindly

Existing records already live in Cloudflare. A plain **`terraform apply` with an empty state will try to create duplicates** and can fail or cause conflicts.

**Before** the first merge that applies:

1. Configure Terraform Cloud + GitHub secrets (below).
2. **Import** each existing record into state (one-time), or use `terraform import` in a loop — see [Importing](#importing-existing-records).
3. Run `terraform plan` until it shows **no changes** (or only intentional edits).

## GitHub configuration

### Secrets

| Name | Description |
|------|-------------|
| `CLOUDFLARE_API_TOKEN` | Zone:DNS:Edit, Zone:Zone:Read |
| `CLOUDFLARE_ZONE_ID` | Zone ID for `joshi1.com` |
| `TF_API_TOKEN` | Terraform Cloud API token |

### Variables

| Name | Description |
|------|-------------|
| `TF_CLOUD_ORGANIZATION` | Terraform Cloud org (replaces `CHANGEME` in `backend.tf.example`) |

Create workspace **`joshi1-infra-dns`** in Terraform Cloud (or rename in `dns/backend.tf.example` and keep CI in sync).

## Local usage

```bash
cd dns
cp terraform.tfvars.example terraform.tfvars
# Fill cloudflare_api_token and cloudflare_zone_id

terraform init
terraform fmt -recursive
terraform validate
terraform plan
```

For Terraform Cloud locally: `cp backend.tf.example backend.tf`, set your org, `terraform init`.

## Importing existing records

For each `cloudflare_record` in `dns/records.tf`, import using the **DNS record ID** from the Cloudflare API or dashboard:

```bash
cd dns
terraform import 'cloudflare_record.a_ai' "<ZONE_ID>/<RECORD_ID>"
```

List record IDs:

```bash
export CLOUDFLARE_ZONE_ID="..."
export CLOUDFLARE_API_TOKEN="..."
curl -sS "https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_ZONE_ID}/dns_records?per_page=500" \
  -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
  | jq -r '.result[] | "\(.type)\t\(.name)\t\(.id)"'
```

Match each row to the matching resource in `records.tf` (by type + name), then run `terraform import` for all 36 resources. After that, `terraform plan` should be clean.

## Updating DNS after the first import

1. Edit `dns/records.tf` (or add a new `cloudflare_record`).
2. Open a PR → review the plan comment → merge to apply.

## Re-syncing from a new Cloudflare export

Download a fresh zone file from Cloudflare, diff against `records.tf`, and update Terraform so the file stays the source of truth.

## Public repo note

Do not commit `terraform.tfvars` or API tokens. The zone export is mostly non-secret; it does list hostnames and targets (expected for DNS repos).
