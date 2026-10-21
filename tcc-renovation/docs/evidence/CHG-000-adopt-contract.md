# CHG-000: Adopt GitHub `tcc-renovation` as authoritative execution-contract layer

- Mission ID: TCC-RENO-ADOPT
- UTC timestamp: 2026-10-21
- Initiating principal: Nicole Montederamos (owner) — adoption + full-automation permission granted this session
- Approval reference: ADR-0002 (this repo), session decision 2026-10-21
- Machines: none mutated (governance-only; this repo + feature branch)
- Services: none mutated (live `/root/tcc` TCC API v0.3.0 untouched)

## Intended change
Adopt this repo as the authoritative execution-contract/governance layer over Handbook v2.0
(ADR-0002), close the two P0 self-consistency gaps, and publish a reconciliation of the active
renovation onto the P0–P10 structure. **No production mutation.**

## Dependencies and preconditions
- ADR-0001 in force (Handbook v2.0 = primary standard; current observation outranks documents).
- Live TCC read-only facts captured (alembic head `0010_promotions`, `public` schema).

## Files/configuration changed (in this repo only)
- `tcc-renovation/docs/adr/ADR-0002-adopt-github-execution-contract.md` (new)
- `tcc-renovation/docs/evidence/RECONCILIATION-20261021.md` (new)
- `tcc-renovation/docs/evidence/CHG-000-adopt-contract.md` (new, this file)
- `.gitignore` (new — closes P0 gap)
- `tcc-renovation/.gitleaks.toml` (new — closes P0 "secret scan" gate)
- `tcc-renovation/tests/**/__pycache__/*.pyc` (untracked via `git rm --cached`)

## Secret references used
None. Reconciliation references evidence by path + hash/fingerprint only.

## Pre-change evidence and hashes
- Repo baseline: single upstream commit `904ef63` ("Add files via upload"), 28 files.
- Live TCC: `select version_num from alembic_version` → `0010_promotions`; schemas → `public` only.

## Backup and restore proof
Not applicable — no production state changed. Operational backups for later phases already exist
under `/root/work/tcc-renovation/phase0/backups/` with a passed restore-test.

## Commands executed
- `git clone` the repo; `git checkout -b` feature branch; read-only `docker exec … psql` queries.
- `make preflight` (passed); `git rm --cached` the committed `.pyc` files.

## Test results
- `make preflight`: PASS ("no production mutation performed").
- SQL contract + OPA policy tests: PASS (see commit CI / local `make test`).

## Post-change evidence
P0 exit gate now satisfied: `.gitignore` present, Gitleaks config present, scripts remain
read-only/dry-run by default, no secrets committed.

## Rollback procedure and rehearsal result
Governance-only. `git revert` this commit / delete the feature branch. No production rollback
needed; nothing in `/root/tcc` or `/root/work/tcc-renovation/` was modified.

## Unresolved risks
- P4 live-schema design conflict (flat `public` vs repo `tcc_*`) — must be resolved before any P4 apply.
- Authorization drift vs ADR-0001 (local Phase 1/2/8 activity) — confirm owner approvals.
- `113.19.183.185` and non-standard open ports — carried from P1 unknowns.
