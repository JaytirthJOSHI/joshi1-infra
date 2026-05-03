#!/usr/bin/env bash
# List Cloudflare DNS record IDs for terraform import (requires jq).
set -euo pipefail
: "${CLOUDFLARE_ZONE_ID:?Set CLOUDFLARE_ZONE_ID}"
: "${CLOUDFLARE_API_TOKEN:?Set CLOUDFLARE_API_TOKEN}"

curl -sS "https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_ZONE_ID}/dns_records?per_page=500" \
  -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
  -H "Content-Type: application/json" \
  | jq -r '.result[] | "\(.type)\t\(.name)\t\(.id)\tproxied=\(.proxied)\t\(.content)"'
