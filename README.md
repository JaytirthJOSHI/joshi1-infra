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

## First-time setup (do this once)

Follow in order. **Do not merge PRs that trigger `terraform apply` until imports are done and `terraform plan` is clean.**

### 1. Terraform Cloud

1. Sign in at [app.terraform.io](https://app.terraform.io).
2. Create an **organization** (if you do not have one).
3. **Workspaces → New workspace → CLI-driven workflow** (or “No VCS”).
4. Workspace name: **`joshi1-infra-dns`** (or change `dns/backend.tf.example` and the CI sed to match).
5. Open **Settings → General → Execution mode** and set **Local** (Terraform runs on your laptop / GitHub runner; only **state** lives in Terraform Cloud). Save.

### 2. Terraform Cloud token

1. **User settings → Tokens** (or org settings) → create an API token with access to that workspace.
2. **GitHub → your repo → Settings → Secrets → Actions** → add **`TF_API_TOKEN`** with that value.
3. **Actions → Variables** → add **`TF_CLOUD_ORGANIZATION`** = your Terraform Cloud org name (exact string).

### 3. Cloudflare token + zone ID

1. Cloudflare **My Profile → API Tokens** → create a token with **Zone → DNS → Edit** and **Zone → Zone → Read** for `joshi1.com`.
2. GitHub **Secrets**: **`CLOUDFLARE_API_TOKEN`**, **`CLOUDFLARE_ZONE_ID`** (zone overview in the dashboard).

### 4. Local: backend + login

```bash
cd /path/to/joshi1-infra/dns
cp backend.tf.example backend.tf
# Edit backend.tf: replace CHANGEME with your Terraform Cloud org name
terraform login   # opens browser; or set TF_TOKEN_app_terraform_io for CI-style non-interactive
```

### 5. Local: variables + init

```bash
cp terraform.tfvars.example terraform.tfvars
# Set cloudflare_api_token and cloudflare_zone_id (or export TF_VAR_...)

terraform init
terraform validate
```

### 6. Import existing DNS into state (critical)

**Do not `terraform apply` before this.** Generate import commands from the live zone (matches all **34** `cloudflare_record` resources):

```bash
export CLOUDFLARE_ZONE_ID="paste-zone-id"
export CLOUDFLARE_API_TOKEN="paste-token"

cd dns
../scripts/gen-imports.py > /tmp/tf-imports.sh
less /tmp/tf-imports.sh    # sanity check
bash /tmp/tf-imports.sh    # may take a minute; ignore "already imported" if re-run
terraform plan
```

You want **`No changes`** (or only tiny TTL/proxy drift you accept). If anything errors, fix `gen-imports.py` / records and re-run.

### 7. Push to GitHub

After **`terraform plan` is clean** with remote state, merge normally. CI will plan on PRs and apply on `main` using the same state.

---

## First deploy — reminder

Existing records already live in Cloudflare. An **`terraform apply` on an empty state creates duplicates**. Always **import** first (step 6 above).

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

Match each row to the matching resource in `records.tf` (by type + name + content), or use **`scripts/gen-imports.py`** to generate all `terraform import` lines. There are **34** `cloudflare_record` resources. After importing, `terraform plan` should be clean.

## Updating DNS after the first import

1. Edit `dns/records.tf` (or add a new `cloudflare_record`).
2. Open a PR → review the plan comment → merge to apply.

## Re-syncing from a new Cloudflare export

Download a fresh zone file from Cloudflare, diff against `records.tf`, and update Terraform so the file stays the source of truth.

## Public repo note

Do not commit `terraform.tfvars` or API tokens. The zone export is mostly non-secret; it does list hostnames and targets (expected for DNS repos).
