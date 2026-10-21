#!/usr/bin/env bash
# P3 stabilization — safe, reversible control-plane fixes.
#
# Read-only by default:  scripts/stabilize/p3.sh            (status)
# Apply one item:        scripts/stabilize/p3.sh <item>     (asks for a typed confirm)
#
# Items (each prints its exact rollback before acting):
#   cap-inference     CHG-007  cap llama.cpp local model (-t 6->2, ctx 64k->8k) via drop-in
#   mask-dead-units   CHG-008  mask ONLY the inert failed units (xrdp, xrdp-sesman,
#                              systemd-networkd-wait-online). Leaves bt_pym/pythonmamager
#                              (aaPanel-managed) for the owner.
#   docker-clean      CHG-011  reclaim build cache + dangling images only (never volumes)
#
# Nothing here touches Hermes config, Telegram, Postgres, nginx, or running app data.
set -uo pipefail
DROPIN_DIR="$HOME/.config/systemd/user/slicklab-local-model.service.d"
DROPIN="$DROPIN_DIR/10-cap.conf"

confirm(){ printf '\033[33m%s\033[0m\n' "$1"; read -rp "Type 'YES' to proceed: " a; [ "$a" = YES ]; }

status(){
  echo "== load / memory / swap =="; uptime; free -h
  echo; echo "== failed units =="; systemctl --failed --no-pager
  echo; echo "== local inference =="; systemctl --user is-active slicklab-local-model 2>/dev/null
  ps -eo pid,pcpu,pmem,rss,args | grep '[l]lama-server' || echo "(llama-server not running)"
  echo; echo "== drop-in present? =="; [ -f "$DROPIN" ] && echo "yes: $DROPIN" || echo "no (default -t 6 / ctx 65536)"
  echo; echo "== docker reclaimable =="; docker system df
}

cap_inference(){
  echo "ROLLBACK: rm -rf '$DROPIN_DIR'; systemctl --user daemon-reload; systemctl --user restart slicklab-local-model"
  confirm "CHG-007: cap local model to -t 2 / --ctx-size 8192 and restart it (brief blip)." || { echo aborted; return 1; }
  mkdir -p "$DROPIN_DIR"
  cat > "$DROPIN" <<'EOF'
[Service]
ExecStart=
ExecStart=/opt/llama.cpp/build/bin/llama-server \
  -m /opt/models/qwen2.5-3b-instruct-q4_k_m.gguf \
  --host 127.0.0.1 --port 8081 \
  -t 2 --ctx-size 8192 --n-gpu-layers 0
EOF
  systemctl --user daemon-reload
  systemctl --user restart slicklab-local-model
  sleep 3
  echo "== health =="; curl -s -m 5 -o /dev/null -w 'llama :8081 -> %{http_code}\n' http://127.0.0.1:8081/health || true
  systemctl --user is-active slicklab-local-model
  echo "ACCEPTANCE: load should fall over the next minutes; :8081 still answers."
}

mask_dead_units(){
  local units="xrdp.service xrdp-sesman.service systemd-networkd-wait-online.service"
  echo "ROLLBACK: systemctl unmask $units"
  confirm "CHG-008: mask inert failed units ($units). bt_pym/pythonmamager left untouched." || { echo aborted; return 1; }
  systemctl mask $units
  systemctl reset-failed $units 2>/dev/null || true
  systemctl --failed --no-pager
}

docker_clean(){
  echo "Before (record digests): docker image ls --digests > evidence first (RB-013)."
  echo "ROLLBACK: images are re-pullable by digest; build cache regenerates. Volumes are NOT touched."
  confirm "CHG-011: docker builder prune -f + docker image prune -f (dangling only; no volumes)." || { echo aborted; return 1; }
  docker builder prune -f
  docker image prune -f
  docker system df
}

case "${1:-status}" in
  status)          status ;;
  cap-inference)   cap_inference ;;
  mask-dead-units) mask_dead_units ;;
  docker-clean)    docker_clean ;;
  *) echo "unknown item: $1"; echo "use: status | cap-inference | mask-dead-units | docker-clean"; exit 2 ;;
esac
