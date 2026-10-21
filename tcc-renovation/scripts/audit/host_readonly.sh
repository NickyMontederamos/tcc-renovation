#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../lib/common.sh"
log "read-only host audit"
printf '\n== uname ==\n'; uname -a
printf '\n== uptime ==\n'; uptime
printf '\n== memory ==\n'; free -h
printf '\n== filesystem ==\n'; df -hT
printf '\n== listeners ==\n'; ss -lntup 2>/dev/null || true
printf '\n== failed units ==\n'; systemctl --failed --no-pager 2>/dev/null || true
printf '\n== docker ps ==\n'; docker ps --format '{{.ID}} {{.Names}} {{.Status}}' 2>/dev/null || true
log "audit complete; redirect output to approved evidence storage"
