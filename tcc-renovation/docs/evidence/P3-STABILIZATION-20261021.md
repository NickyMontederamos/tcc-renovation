# P3 stabilization — measured baseline + ready change records (2026-10-21)

All actions are packaged in `scripts/stabilize/p3.sh` (read-only `status` by default; each
mutation asks for a typed confirm and prints its rollback first). Claude is classifier-blocked
from running the mutations on prod; the owner runs the script, or grants a permission rule.

## Measured baseline (read-only, 2026-10-21 ~12:19 UTC)
- Load average **11.23 / 10.56 / 7.00** on 6 vCPU — WORSE than the 2026-10-20 baseline (~8.84).
- Memory 6.4Gi used / 1.6Gi free; **Swap 8.1Gi / 11Gi used**.
- Top consumer: **`llama-server`** (local model) — 23.6% CPU, **1.9 GB RSS (15.6%)**, `-t 6`
  (all cores), `--ctx-size 65536`, CPU-only. systemd user unit `slicklab-local-model.service`
  (`/etc/xdg/systemd/user/`). A second stack `ollama.service` is inactive/dead (no action).
- Docker reclaimable: 6.5 GB images + 618 MB volumes + 539 MB build cache; disk only 53% used
  (91 GB free) — disk is NOT the pressure, so Docker cleanup is low-urgency.
- Failed units: `xrdp`, `xrdp-sesman`, `systemd-networkd-wait-online` (inert/leftover) and
  `bt_pym`, `pythonmamager` (aaPanel-managed — do NOT mask blindly; may hide a real app).

> Load is in the contract's caution zone ("swap/load pressure materially worsens"). Prefer a
> quiet window and watch `uptime`/`free -h` after each step; roll back if pressure rises.

## CHG-007 — cap local inference  (HIGHEST VALUE)
- **Why:** `llama-server` is the single biggest CPU+RAM driver; 64K context on a 3B model holds a
  large KV cache and `-t 6` starves everything else.
- **Change:** drop-in override -> `-t 2 --ctx-size 8192`. Shipped unit untouched.
- **Apply:** `scripts/stabilize/p3.sh cap-inference`
- **Backup/rollback:** `rm -rf ~/.config/systemd/user/slicklab-local-model.service.d && systemctl --user daemon-reload && systemctl --user restart slicklab-local-model`
- **Acceptance:** `:8081/health` still answers; load trends down over minutes (RB-005 covers failure).

## CHG-008 — mask inert failed units
- **Change:** mask ONLY `xrdp`, `xrdp-sesman`, `systemd-networkd-wait-online` (not running; VNC is
  the real remote-desktop path via Xtigervnc :5901). Leaves `bt_pym`/`pythonmamager` for the owner.
- **Apply:** `scripts/stabilize/p3.sh mask-dead-units`
- **Rollback:** `systemctl unmask xrdp.service xrdp-sesman.service systemd-networkd-wait-online.service`
- **Note:** does NOT reduce load (units are already dead) — this only cleans the health signal.

## CHG-011 — targeted Docker cleanup (low urgency)
- **Change:** `docker builder prune -f` + `docker image prune -f` (dangling only). **No volumes.**
- **Apply:** `scripts/stabilize/p3.sh docker-clean`  (record `docker image ls --digests` first, RB-013)
- **Rollback:** images re-pullable by digest; build cache regenerates.

## Owner-gated / Hermes-owned (NOT scripted here — need their window + judgment)
- **CHG-001/002 Telegram** ownership + path resilience — Hermes-owned routes.
- **CHG-003 canonical Hermes config** — never restart Hermes from inside its own tree (CLAUDE.md).
- **CHG-004/005 singleton & browser-controller de-dup** — verify no dependents first.
- **CHG-006 Celery right-sizing** — measure growth-worker queue depth before changing concurrency.
- **bt_pym / pythonmamager** — identify the aaPanel app behind them; fix or remove at source.
