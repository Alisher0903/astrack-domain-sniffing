#!/bin/bash

CURRENT="$1"
PREVIOUS="$2"

if [[ -z "$CURRENT" || -z "$PREVIOUS" ]]; then
    echo "Usage: $0 <current_snapshot> <previous_snapshot>"
    exit 1
fi

mkdir -p reports

CURRENT_SUBS=$(mktemp)
PREVIOUS_SUBS=$(mktemp)

jq -r '.subdomains[]' "$CURRENT" | sort > "$CURRENT_SUBS"
jq -r '.subdomains[]' "$PREVIOUS" | sort > "$PREVIOUS_SUBS"

NEW_SUBDOMAINS=$(comm -13 "$PREVIOUS_SUBS" "$CURRENT_SUBS" | jq -R . | jq -s .)
REMOVED_SUBDOMAINS=$(comm -23 "$PREVIOUS_SUBS" "$CURRENT_SUBS" | jq -R . | jq -s .)

NEW_PORTS=$(jq -n \
  --slurpfile current "$CURRENT" \
  --slurpfile previous "$PREVIOUS" '
    ($current[0].ports // {}) as $c |
    ($previous[0].ports // {}) as $p |
    [
      $c
      | to_entries[]
      | .key as $host
      | .value[] as $port
      | select((($p[$host] // []) | index($port)) | not)
      | {
          host: $host,
          port: $port
        }
    ]
  ')

REMOVED_PORTS=$(jq -n \
  --slurpfile current "$CURRENT" \
  --slurpfile previous "$PREVIOUS" '
    ($current[0].ports // {}) as $c |
    ($previous[0].ports // {}) as $p |
    [
      $p
      | to_entries[]
      | .key as $host
      | .value[] as $port
      | select((($c[$host] // []) | index($port)) | not)
      | {
          host: $host,
          port: $port
        }
    ]
  ')

jq -n \
  --argjson new_subdomains "$NEW_SUBDOMAINS" \
  --argjson removed_subdomains "$REMOVED_SUBDOMAINS" \
  --argjson new_ports "$NEW_PORTS" \
  --argjson removed_ports "$REMOVED_PORTS" \
  '{
      new_subdomains: $new_subdomains,
      removed_subdomains: $removed_subdomains,

      new_ports: $new_ports,
      removed_ports: $removed_ports,

      new_web_hosts: [],

      title_changes: []
   }' > reports/diff.json

rm -f "$CURRENT_SUBS" "$PREVIOUS_SUBS"

echo "[OK] Diff written to reports/diff.json"
