# Reconciliation: active renovation → GitHub `P0–P10` contract

- UTC: 2026-10-21
- Author: Claude implementation agent (verification + reconciliation authority per ADR-0001)
- Governs: operational workspace `/root/work/tcc-renovation/` and live control plane `/root/tcc`
- Precedence: current direct read-only observation outranks documents (ADR-0001)

## How to read this
The active work uses **Handbook/local** phase numbers. This repo uses a different **P0–P10**
cut. The table maps local evidence onto the repo's phases with a verified status. Evidence is
referenced by **path + hash/fingerprint only** — never secret values.

| Repo phase | Scope | Status | Evidence (local, off-Git) | Open gate / owner decision |
|---|---|---|---|---|
| **P0** Repository & control contract | This contract repo + ADR-0002 | **DONE (this commit)** | `docs/adr/ADR-0002*`, `.gitignore`, `.gitleaks.toml` added; `.pyc` untracked | — |
| **P1** Baseline & ownership inventory | RB-02 read-only VPS inventory + drift | **DONE** | `/root/work/tcc-renovation/phase0/rb02-20261020/` (61 files, `evidence-manifest.json`): component-inventory, classification-counts, drift-report, risks, NO-MUTATIONS statement | Resolve `113.19.183.185` authorization; close port-exposure unknowns U-01/02/03 (888/8077/8080/8768/3000/887/42622/7373) |
| **P2** Verified recovery | Off-host, tested restore | **PARTIAL** | `phase0/backups/` (pg dumps for tcc/stage/growth/leads/billionmail, mariadb, colnex-state, nginx-vhosts, shared-mem) + `phase0/restore-test/` (source vs restored rowcounts match) | Off-host **Restic** + **pgBackRest** (or equivalent) not yet established; backups not yet encrypted/off-host |
| **P3** Stabilize production (CHG-001…012) | Telegram owner, canonical Hermes config, singleton dedup, celery sizing, local inference, failed units, token-shaped files, vhosts, docker cleanup | **MOSTLY NOT DONE** | Baseline: load ~8.84, swap 9.5/11 GiB; 5 failed units (bt_pym, pythonmamager, networkd-wait-online, xrdp-sesman, xrdp) → CHG-008 | Each CHG is an owner-gated production mutation; swap/load exit-gate not yet met |
| **P4** TCC data foundation (`tcc_*` schemas) | Isolated governance schemas | **DISPUTED — DO NOT AUTO-APPLY** | Live `deploy-postgres-1` db `tcc`: alembic head **`0010_promotions`**, flat tables in **`public`** (registry_entities, identities, agent_profiles, memory_records, rag_sources, skills, validation_runs, mcp_tools, promotion_records, audit_events). **No `tcc_*` schemas exist.** | Repo `schemas/sql/001_tcc_schemas_up.sql` creates a *different* `tcc_*` design (machines/agents/missions/jobs/…). Owner must decide: keep live flat/`public` design, or migrate to namespaced `tcc_*`. Applying the repo migration as-is would create parallel, unused/conflicting schemas. |
| **P5** Worker enrollment & scheduler | GoldenLegacy, Bobsicles | **NOT DONE / NOT AUTHORIZED** | `inventory/machines.example.yml` lists both with `scheduling_enabled: false`; o9yown unclassified | Remote-worker enrollment explicitly **not authorized** by ADR-0001 |
| **P6** Governed MCP fabric | Policy gateway in front of MCP tools | **BUILT & STAGED (inert)** | Local "Phase 5" `phase5/bridge-shim/` (`tcc_gate.py`, `INTEGRATION.md`); `/mcp/authorize`; `tcc-ops.sh` has `gate-canary`/`gate-enforce`/`gate-disable` | Inert until env set; apply is owner/Hermes action. Needs Phase-5 `/mcp/authorize` merged+deployed and a `mcp:call` identity |
| **P7** REA static analysis | Ghidra on worker only | **NOT STARTED** | — | Worker-only; depends on P5 |
| **P8** Browser/coding workers | Off-control-plane | **NOT STARTED (local `phase8/` is a TCC predeploy, not this scope)** | `phase8/predeploy-20261021-045047/` (tcc-prod.dump) = a TCC app predeploy snapshot, **not** browser-worker work — numbering collision | Clarify local `phase8` intent vs repo P8 |
| **P9** Observability | OTel + Prometheus/Grafana | **NOT STARTED** | — | — |
| **P10** Advanced pillar evals | Temporal/NATS/Qdrant/… | **DEFERRED** | ADR-0001 defers these pillars pending ADR + benchmark | Each needs its own ADR |

## Items flagged DISPUTED / UNKNOWN (require owner resolution)
1. **P4 schema design conflict** (above) — highest priority before any P4 apply.
2. **Phase-numbering collision** — local Phase 1/2/5/8 ≠ repo P1/P2/P5/P8. This repo's P0–P10 is
   now the canonical cut (ADR-0002); local dirs remain as evidence, mapped above.
3. **Authorization drift vs ADR-0001** — ADR-0001 authorized *Phase 0 only*, but local evidence
   shows a Phase 1 deploy (live TCC v0.3.0), Phase 2 token seed, and Phase 8 predeploy. Confirm
   these had owner approval in later sessions, or mark for review. Not asserting fault; flagging
   for the record per the contract.
4. **113.19.183.185** and the non-standard open ports — carried forward from P1 unknowns.

## Next authorized (read-only / reversible) actions
- Keep this reconciliation current as the single source of phase truth.
- Run `make preflight`, `make audit`, `make web-check` and file results under `docs/evidence/`
  (redacted summaries + hashes; raw stays off-Git).
- Draft `CHG-###` records (not executed) for the P3 stabilization items so each is ready for a
  one-word owner approval.

## Explicitly NOT done here (owner-gated mutations)
Applying P4 to the live DB, enabling MCP gate enforcement, enrolling workers, restarting
services, editing nginx/vhosts, rotating credentials, and P7–P10. These remain gated behind a
`CHG-###` + approval + backup + proven rollback, per the adopted contract.
