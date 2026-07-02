#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

DOMAIN="$1"

subfinder="$SCRIPT_DIR/../go/bin/subfinder"
assetfinder="$SCRIPT_DIR/../go/bin/assetfinder"

if [[ -z "$DOMAIN" ]]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

(
    "$subfinder" -silent -d "$DOMAIN"
    "$assetfinder" --subs-only "$DOMAIN"
) | sort -u
