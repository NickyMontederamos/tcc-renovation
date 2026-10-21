#!/usr/bin/env bash
set -euo pipefail
log(){ printf '%s %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*"; }
fail(){ log "ERROR: $*" >&2; exit 1; }
require_cmd(){ command -v "$1" >/dev/null 2>&1 || fail "missing command: $1"; }
require_apply_guard(){
  local apply="${1:-}"
  [[ "$apply" == "--apply" ]] || fail "dry-run safety: pass --apply only after approval"
  [[ -n "${CHANGE_ID:-}" ]] || fail "CHANGE_ID is required"
  [[ -f "${APPROVAL_FILE:-/nonexistent}" ]] || fail "APPROVAL_FILE must reference an existing approval marker"
  [[ -f "${BACKUP_PROOF_FILE:-/nonexistent}" ]] || fail "BACKUP_PROOF_FILE must reference verified restore evidence"
}
