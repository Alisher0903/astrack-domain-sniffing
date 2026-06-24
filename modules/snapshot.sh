#!/bin/bash

DOMAIN="$1"

if [[ -z "$DOMAIN" ]]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

SUBDOMAINS_FILE="tmp/subdomains.txt"
PORTS_FILE="tmp/ports.txt"
WEB_FILE="tmp/web.jsonl"

if [[ ! -f "$SUBDOMAINS_FILE" ]]; then
    echo "[ERROR] Missing file: $SUBDOMAINS_FILE"
    exit 1
fi

if [[ ! -f "$PORTS_FILE" ]]; then
    echo "[ERROR] Missing file: $PORTS_FILE"
    exit 1
fi

if [[ ! -f "$WEB_FILE" ]]; then
    echo "[ERROR] Missing file: $WEB_FILE"
    exit 1
fi

mkdir -p "snapshots/$DOMAIN"

jq -n \
    --arg date "$(date '+%Y-%m-%d %H:%M:%S')" \
    --arg domain "$DOMAIN" \
    --slurpfile subdomains <(jq -R -s 'split("\n") | map(select(length > 0))' "$SUBDOMAINS_FILE") \
    --slurpfile ports <(
        awk -F':' '
        {
            host=$1
            split($2, p, ",")
            printf "{\"%s\":[", host
            for (i=1; i<=length(p); i++) {
                printf "%s%s", p[i], (i<length(p) ? "," : "")
            }
            print "]}"
        }
        ' "$PORTS_FILE" | jq -s 'add'
    ) \
    --slurpfile web <(
        jq -s '
            map({
                key: .host,
                value: {
                    status: (.status_code | tostring),
                    title: (.title // ""),
                    url: (.url // ""),
                    webserver: (.webserver // ""),
                    tech: (.tech // [])
                }
            })
            | from_entries
        ' "$WEB_FILE"
    ) \
    '
    {
        scan_date: $date,
        domain: $domain,
        subdomains: $subdomains[0],
        ports: $ports[0],
        web: $web[0],
        risk_findings: []
    }
    ' > "snapshots/$DOMAIN/latest.json"

TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
cp "snapshots/$DOMAIN/latest.json" "snapshots/$DOMAIN/$TIMESTAMP.json"

echo "[OK] Snapshot created: snapshots/$DOMAIN/latest.json"
echo "[OK] Snapshot archived: snapshots/$DOMAIN/$TIMESTAMP.json"
