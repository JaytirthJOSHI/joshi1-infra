# joshi1-infra

DNS and Cloudflare routing for **joshi1.com** as code: Terraform with the official Cloudflare provider, GitHub Actions for plan-on-PR and apply-on-merge, and Terraform Cloud for remote state.

## Layout

| Path | Purpose |
|------|---------|
| `dns/main.tf` | Provider + zone data source |
| `dns/variables.tf` | API token, zone ID, Pages CNAME targets, Worker script names |
| `dns/records.tf` | DNS records (Pages + Worker hostnames) |
| `dns/workers.tf` | Worker routes `firefly.joshi1.com/*` and `go.joshi1.com/*` |
| `dns/outputs.tf` | Useful outputs after apply |
| `dns/backend.tf.example` | Terraform Cloud backend (copied in CI) |
| `.github/workflows/terraform.yml` | Plan on PR, apply on `main` |

GitHub Actions expects workflow files under `.github/workflows/` with a `.yml` / `.yaml` suffix (not `.tf`).

## What gets managed

| Hostname | Purpose |
|----------|---------|
| `joshi1.com` | Cloudflare Pages (apex CNAME, proxied) |
| `firefly.joshi1.com` | Cloudflare Worker (proxied AAAA placeholder + Worker route) |
| `go.joshi1.com` | Cloudflare Worker (Sink fork; same pattern) |
| `admin.joshi1.com` | Cloudflare Pages |
| `net.joshi1.com` | Cloudflare Pages (placeholder) |

Worker subdomains use a proxied `AAAA` record (`100::`) so the hostname resolves on Cloudflare’s edge while `cloudflare_workers_route` sends traffic to your deployed Worker scripts. The Worker scripts themselves are still deployed with Wrangler or your usual pipeline; Terraform only binds routes and DNS.

### Alternative: Worker custom domains

If you prefer the dashboard “Custom domains” model only, you can replace the AAAA + route pair with `cloudflare_workers_domain` (requires `CLOUDFLARE_ACCOUNT_ID` and Account-scoped API permissions). See the [provider docs](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/workers_domain). Do not duplicate the same hostname with both routes and `workers_domain` without checking Cloudflare for conflicts.

## Prerequisites

1. **Cloudflare** zone for `joshi1.com` on your account.
2. **API token** with at least:
   - Zone → DNS → Edit  
   - Zone → Zone → Read  
   - Zone → Workers Routes → Edit (for Worker routes)  
   Create tokens under **My Profile → API Tokens**. The “Edit zone DNS” template is close; add **Workers Routes → Edit** for this repo.
3. **Terraform Cloud** (free tier is fine) organization and a CLI-driven workspace named **`joshi1-infra-dns`** (or change the name in `dns/backend.tf.example` and the workflow).
4. **GitHub** repository secrets and variables (below).

## GitHub configuration

### Secrets (Settings → Secrets and variables → Actions)

| Name | Description |
|------|-------------|
| `CLOUDFLARE_API_TOKEN` | Cloudflare API token |
| `CLOUDFLARE_ZONE_ID` | Zone ID for `joshi1.com` |
| `TF_API_TOKEN` | Terraform Cloud API token with access to the workspace |

### Variables (same settings page, **Variables** tab)

| Name | Example | Description |
|------|---------|-------------|
| `TF_CLOUD_ORGANIZATION` | `your-org` | Terraform Cloud organization name (replaces `CHANGEME` in `backend.tf.example`) |
| `PAGES_ROOT_CNAME_TARGET` | `my-site.pages.dev` | Pages custom domain target for the root site |
| `PAGES_ADMIN_CNAME_TARGET` | `admin-site.pages.dev` | Admin dashboard Pages target |
| `PAGES_NET_CNAME_TARGET` | `net-site.pages.dev` | Future `net` project (use a real or temporary Pages hostname) |
| `WORKER_FIREFLY_SCRIPT_NAME` | `firefly` | Worker name in the dashboard |
| `WORKER_GO_SCRIPT_NAME` | `go` | Worker name for the Sink fork |

The workflow writes `dns/backend.tf` from `backend.tf.example` on each run so local development can stay on local state while CI always uses Terraform Cloud.

## Local usage

```bash
cd dns
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with real values (file is gitignored).

terraform init
terraform fmt -recursive
terraform validate
terraform plan
```

For local Terraform Cloud state, copy the backend example and set your org:

```bash
cp backend.tf.example backend.tf
# Edit CHANGEME → your Terraform Cloud organization
terraform init
```

`backend.tf` is gitignored so you can use Terraform Cloud locally without committing org-specific config.

## Importing existing records

After the first `terraform init`, import resources that already exist in Cloudflare so Terraform adopts them instead of trying to recreate them.

1. Find IDs in the Cloudflare dashboard (**DNS → Records**; for routes, **Workers & Pages → your Worker → Routes**), or use the API / `curl`.
2. Import using the addresses Terraform expects, for example:

```bash
# DNS record (record ID from the dashboard or API)
terraform import 'cloudflare_record.root_pages' "${CLOUDFLARE_ZONE_ID}/${RECORD_ID}"

# Worker route (route ID from the API; import format is zone_id/route_id)
terraform import 'cloudflare_workers_route.firefly' "${CLOUDFLARE_ZONE_ID}/${ROUTE_ID}"
```

3. Run `terraform plan` until the diff is empty (you may need to adjust `records.tf` to match TTL, `proxied`, or `comment` exactly).

If you prefer a greenfield cutover, you can delete conflicting dashboard records once (carefully), then `terraform apply` to recreate them under management—only do this if you understand the blast radius.

## Adding a new subdomain

1. Add a `cloudflare_record` (and optional `cloudflare_workers_route` or Pages CNAME) in `dns/records.tf` or a new `.tf` file in `dns/`.
2. Add variables if the value should differ per environment.
3. Run `terraform fmt` and open a PR; confirm the plan comment looks correct, then merge to apply.

## CI behavior

- **Pull requests targeting `main`**: `terraform fmt -check`, `init`, `validate`, `plan`. The plan is posted as a sticky PR comment.
- **Push to `main`**: same through `init`, then `terraform apply -auto-approve`.

Workflow and Terraform files under `dns/` trigger runs.

## Next step

When this repo is wired to GitHub and Terraform Cloud, we can import your live `joshi1.com` records into state and reconcile any drift.
