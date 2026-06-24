#!/bin/bash

DOMAIN="$1"

if [[ -z "$DOMAIN" ]]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

(
    subfinder -silent -d "$DOMAIN"
    assetfinder --subs-only "$DOMAIN"
) | sort -u
