#!/bin/bash

INPUT_FILE="$1"

if [[ -z "$INPUT_FILE" ]]; then
    echo "Usage: $0 <subdomains_file>"
    exit 1
fi

if [[ ! -f "$INPUT_FILE" ]]; then
    echo "[ERROR] File not found: $INPUT_FILE"
    exit 1
fi

while read -r host; do
    [[ -z "$host" ]] && continue

    ports=$(nmap -Pn --top-ports 20 "$host" 2>/dev/null \
        | awk '/open/ {print $1}' \
        | cut -d "/" -f1 \
        | paste -sd "," -)

    if [[ -n "$ports" ]]; then
        echo "$host:$ports"
    fi
done < "$INPUT_FILE"
