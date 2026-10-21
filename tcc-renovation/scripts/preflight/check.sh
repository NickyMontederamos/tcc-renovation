#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../lib/common.sh"
for cmd in git bash awk sed grep sha256sum; do require_cmd "$cmd"; done
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if git ls-files | grep -E '(^|/)(\.env|id_rsa|id_ed25519)$' >/dev/null; then
    fail "tracked secret-like filename detected"
  fi
fi
log "preflight passed; no production mutation performed"
