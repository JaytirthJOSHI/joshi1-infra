#!/usr/bin/env python3
"""Match Cloudflare DNS records to dns/records.tf and print terraform import commands.

Requires:
  export CLOUDFLARE_ZONE_ID=...
  export CLOUDFLARE_API_TOKEN=...

Optional:
  export CLOUDFLARE_ZONE_NAME=joshi1.com   # default
  export RECORDS_TF=/path/to/records.tf    # default: dns/records.tf next to repo root

Usage (from repo root):
  cd dns && ../scripts/gen-imports.py
  cd dns && ../scripts/gen-imports.py | bash   # review output first
"""

from __future__ import annotations

import json
import os
import re
import sys
import urllib.error
import urllib.request


def parse_records_tf(path: str) -> list[dict]:
    text = open(path, encoding="utf-8").read()
    pattern = r'resource\s+"cloudflare_record"\s+"([^"]+)"\s*\{([\s\S]*?)\n\}'
    out: list[dict] = []
    for m in re.finditer(pattern, text):
        label = m.group(1)
        body = m.group(2)

        def grab_str(key: str) -> str | None:
            mm = re.search(r"^\s*" + re.escape(key) + r'\s*=\s*"([^"]*)"', body, re.MULTILINE)
            return mm.group(1) if mm else None

        def grab_int(key: str) -> int | None:
            mm = re.search(r"^\s*" + re.escape(key) + r"\s*=\s*(\d+)\s*$", body, re.MULTILINE)
            return int(mm.group(1)) if mm else None

        typ = grab_str("type")
        name = grab_str("name")
        content = grab_str("content")
        if not typ or name is None or content is None:
            raise SystemExit(f"incomplete block {label}: type/name/content required")
        rec: dict = {
            "tf_label": label,
            "type": typ,
            "name": name,
            "content": content,
        }
        pr = grab_int("priority")
        if pr is not None:
            rec["priority"] = pr
        out.append(rec)
    return out


def norm_short(api_name: str, zone: str) -> str:
    z = zone.rstrip(".").lower()
    raw = api_name.rstrip(".")
    n = raw.lower()
    if n == z:
        return "@"
    suf = "." + z
    if n.endswith(suf):
        return raw[: len(raw) - len(suf)]
    return raw


def norm_content(content: str, rtype: str) -> str:
    c = content.rstrip(".")
    if rtype == "TXT":
        # Cloudflare sometimes returns TXT with surrounding quotes in older APIs; strip one layer.
        if len(c) >= 2 and c[0] == '"' and c[-1] == '"':
            c = c[1:-1]
    return c


def fetch_dns(zone_id: str, token: str) -> list[dict]:
    page = 1
    all_rows: list[dict] = []
    while True:
        url = f"https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records?per_page=500&page={page}"
        req = urllib.request.Request(
            url,
            headers={
                "Authorization": f"Bearer {token}",
                "Content-Type": "application/json",
            },
        )
        try:
            with urllib.request.urlopen(req, timeout=60) as resp:
                data = json.load(resp)
        except urllib.error.HTTPError as e:
            body = e.read().decode("utf-8", errors="replace")
            raise SystemExit(f"Cloudflare API HTTP {e.code}: {body}") from e
        if not data.get("success"):
            raise SystemExit(f"Cloudflare API error: {data}")
        all_rows.extend(data["result"])
        info = data.get("result_info") or {}
        total_pages = info.get("total_pages") or 1
        if page >= total_pages:
            break
        page += 1
    return all_rows


def match_record(want: dict, api_rows: list[dict], zone: str) -> str:
    w_type = want["type"]
    w_name = want["name"]
    w_content = want["content"]
    w_pri = want.get("priority")

    candidates = []
    for r in api_rows:
        if r.get("type") != w_type:
            continue
        if norm_short(r.get("name") or "", zone) != w_name:
            continue
        api_c = norm_content(r.get("content") or "", w_type)
        if api_c != w_content:
            continue
        if w_type == "MX":
            if int(r.get("priority") or 0) != int(w_pri or 0):
                continue
        candidates.append(r["id"])

    if len(candidates) == 1:
        return candidates[0]
    if len(candidates) == 0:
        raise LookupError(
            f"No API match for cloudflare_record.{want['tf_label']} "
            f"({w_type} {w_name!r} {w_content[:50]!r}...)"
        )
    raise LookupError(f"Ambiguous API match for cloudflare_record.{want['tf_label']}: {candidates}")


def main() -> None:
    zone_id = os.environ.get("CLOUDFLARE_ZONE_ID", "").strip()
    token = os.environ.get("CLOUDFLARE_API_TOKEN", "").strip()
    zone_name = os.environ.get("CLOUDFLARE_ZONE_NAME", "joshi1.com").strip()

    if not zone_id or not token:
        print(
            "Set CLOUDFLARE_ZONE_ID and CLOUDFLARE_API_TOKEN in your environment.",
            file=sys.stderr,
        )
        sys.exit(1)

    script_dir = os.path.dirname(os.path.abspath(__file__))
    repo_root = os.path.dirname(script_dir)
    default_tf = os.path.join(repo_root, "dns", "records.tf")
    records_tf = os.environ.get("RECORDS_TF", default_tf)
    if not os.path.isfile(records_tf):
        print(f"Missing {records_tf}", file=sys.stderr)
        sys.exit(1)

    wanted = parse_records_tf(records_tf)
    api_rows = fetch_dns(zone_id, token)

    print("# Generated import commands — review then run (e.g. pipe to bash).", file=sys.stderr)
    print(f"# Zone: {zone_id}  Records in API: {len(api_rows)}  TF resources: {len(wanted)}", file=sys.stderr)

    lines = []
    for w in wanted:
        rid = match_record(w, api_rows, zone_name)
        addr = f"cloudflare_record.{w['tf_label']}"
        lines.append(f"terraform import '{addr}' '{zone_id}/{rid}'")

    for ln in lines:
        print(ln)


if __name__ == "__main__":
    main()
