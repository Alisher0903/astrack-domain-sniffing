#!/bin/bash

DOMAIN="$1"

if [[ -z "$DOMAIN" ]]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

echo "[*] Starting Attack Surface Risk Tracker"
echo "[*] Target: $DOMAIN"

mkdir -p tmp

PREVIOUS_SNAPSHOT=""

if [[ -f "snapshots/$DOMAIN/latest.json" ]]; then
    PREVIOUS_SNAPSHOT=$(mktemp)
    cp "snapshots/$DOMAIN/latest.json" "$PREVIOUS_SNAPSHOT"

    echo "[*] Previous snapshot found"
fi

echo "[*] Running subdomain discovery..."
./modules/subdomain.sh "$DOMAIN" > tmp/subdomains.txt

echo "[*] Running port discovery..."
./modules/ports.sh tmp/subdomains.txt > tmp/ports.txt

echo "[*] Running web fingerprinting..."
./modules/web.sh tmp/subdomains.txt > tmp/web.jsonl

echo "[*] Creating snapshot..."
./modules/snapshot.sh "$DOMAIN"

if [[ -n "$PREVIOUS_SNAPSHOT" ]]; then

    echo "[*] Running diff engine..."
    ./modules/diff.sh \
        "snapshots/$DOMAIN/latest.json" \
        "$PREVIOUS_SNAPSHOT"

    echo "[*] Running risk engine..."
    ./modules/risk.sh reports/diff.json

    echo "[*] Generating HTML report..."
    ./modules/report.sh

    # BU QISMDA AUTO BROWSERDA OCHILISHI UCHUN. NEW VERSION UCHUN.
    # if command -v xdg-open >/dev/null 2>&1; then
    #   xdg-open reports/report.html >/dev/null 2>&1 &
    # else
    #   echo "[INFO] Open manually: reports/report.html"
    # fi

    rm -f "$PREVIOUS_SNAPSHOT"

else
    echo "[*] First scan detected. Skipping diff and risk analysis."
fi

echo
echo "[*] Scan completed"
