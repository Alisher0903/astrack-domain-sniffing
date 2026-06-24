#!/bin/bash

check_dependency() {
    local tool="$1"

    if command -v "$tool" >/dev/null 2>&1; then
        echo "[OK] $tool"
    else
        echo "[ERROR] Missing dependency: $tool"
        return 1
    fi
}
