#!/bin/bash

DIFF_FILE="$1"

if [[ -z "$DIFF_FILE" ]]; then
    echo "Usage: $0 <diff.json>"
    exit 1
fi

if [[ ! -f "$DIFF_FILE" ]]; then
    echo "[ERROR] Diff file not found"
    exit 1
fi

RISK_FINDINGS="[]"

while IFS='|' read -r PORT SEVERITY REASON; do

    MATCHES=$(jq \
      --argjson port "$PORT" \
      '
      .new_ports[]
      | select(.port == $port)
      | {
          severity: "'"$SEVERITY"'",
          host: .host,
          reason: "'"$REASON"'"
        }
      ' "$DIFF_FILE" | jq -s .)

    RISK_FINDINGS=$(jq -n \
      --argjson a "$RISK_FINDINGS" \
      --argjson b "$MATCHES" \
      '$a + $b')

done < config/risky_ports.txt

while IFS='|' read -r KEYWORD SEVERITY REASON; do

    MATCHES=$(jq \
      --arg keyword "$KEYWORD" \
      '
      .title_changes[]
      | select(.new_title | test($keyword; "i"))
      | {
          severity: "'"$SEVERITY"'",
          host: .host,
          reason: "'"$REASON"'"
        }
      ' "$DIFF_FILE" | jq -s .)

    RISK_FINDINGS=$(jq -n \
      --argjson a "$RISK_FINDINGS" \
      --argjson b "$MATCHES" \
      '$a + $b')

done < config/risky_titles.txt

jq -n \
  --argjson findings "$RISK_FINDINGS" \
  '{
      risk_findings: $findings
   }' > reports/risk.json

echo "[OK] Risk report created"
