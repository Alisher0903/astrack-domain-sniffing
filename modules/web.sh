#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

INPUT_FILE="$1"
HTTPX_BIN="$SCRIPT_DIR/../go/bin/httpx"

if [[ -z "$INPUT_FILE" ]]; then
    echo "Usage: $0 <subdomains_file>"
    exit 1
fi

if [[ ! -f "$INPUT_FILE" ]]; then
    echo "[ERROR] File not found: $INPUT_FILE"
    exit 1
fi

if [[ ! -x "$HTTPX_BIN" ]]; then
    echo "[ERROR] ProjectDiscovery httpx not found: $HTTPX_BIN"
    exit 1
fi

"$HTTPX_BIN" -silent -json -title -status-code -follow-redirects -l "$INPUT_FILE" 2>/dev/null
