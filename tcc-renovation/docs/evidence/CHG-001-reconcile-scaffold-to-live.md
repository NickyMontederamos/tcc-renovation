# CHG-001: Reconcile scaffold artifacts to the live architecture

- Mission ID: TCC-RENO-ADOPT
- UTC timestamp: 2026-10-21
- Initiating principal: Nicole Montederamos (owner) — "make the full infrastructure work; edit and fix what won't work in our architecture logic"
- Approval reference: ADR-0002; session decision 2026-10-21
- Machines: none mutated (repo edits + read-only live discovery + one ephemeral throwaway container)
- Services: none mutated (live TCC v0.11.0, all 23 services untouched)

## Intended change
Fix every scaffold artifact that contradicted the deployed architecture so the contract repo
matches and can actually verify the live system. **No production mutation.**

## Discovery (read-only)
- TCC DB `tcc` @ `deploy-postgres-1` (pgvector/pgvector:pg16): Alembic head `0010_promotions`,
  16 tables in `public` (no `tcc_*` schemas).
- Fleet: `docker ps` + `ss -lntn` — 23 services (mix of containers and port-bound host procs).
- Public: `https://slicklab.digital/` -> 200, `https://slicklab.digital/tcc/` -> 401,
  TCC API `127.0.0.1:8100/health` -> 200 v0.11.0.

## Files changed (repo only)
- `schemas/sql/001_tcc_schemas_up.sql` — replaced fictional `tcc_*` design with an idempotent
  REFERENCE MIRROR of the 16 live `public` tables (+ `vector` extension).
- `schemas/sql/001_tcc_schemas_down.sql` — made a safe no-op (rollback is via Alembic; never drop `public`).
- `inventory/services.yml` — replaced 5 placeholder services with the 23 real ones; each has a
  reliable `check` (container | port | process), owner, placement, criticality.
- `inventory/machines.yml` (new) — real control-plane identity (vmi3585023 / 173.249.26.61) + declared workers.
- `inventory/web-endpoints.yml` (new) — real verified endpoints.
- `scripts/verify/service_replicas.py` — rewritten to verify containers, ports, and processes
  (a single host-`ps` substring could not see containerized/port-bound services).
- `policies/opa/tcc.rego` — added control-plane prohibitions (heavy-rea, large-local-model,
  browser-at-scale, worker-only) and high-impact-needs-approval, matching live `/mcp/authorize`.
- `docs/PHASED_IMPLEMENTATION_PLAN.md` — P4 rewritten: data foundation is LIVE/Alembic-owned.
- `Makefile` — `web-check`/`replica-check` point at the real inventories.
- `tests/**` — validate the real contract; guard against reintroducing `tcc_*`.

## Secret references used
None.

## Test results / acceptance
- `make preflight`: PASS.
- `pytest`: 10/10 PASS (SQL-contract + OPA-policy).
- `web_endpoints.py` vs live: 2/2 PASS (apex 200, tcc 401).
- `service_replicas.py` vs live: 23/23 PASS.
- SQL mirror on ephemeral pgvector DB: apply OK, 2nd apply no-op (idempotent), 16 tables,
  `down` left all 16 tables intact. Ephemeral container removed.

## Post-change evidence
Repo artifacts now match the deployed architecture; all checks are green against the live fleet.

## Rollback procedure and rehearsal result
Governance-only. `git revert` this commit / delete the feature branch. No production rollback
needed; the only runtime object created (ephemeral `tcc-schema-check` container) was removed.

## Unresolved risks
- Authorization drift vs ADR-0001 (local Phase 1/2/8 activity) — confirm owner approvals.
- `113.19.183.185` and non-standard open ports (888/8077/8080/8768/3000/887/42622/7373) — P1 unknowns.
- P3 stabilization (swap/load, 5 failed units, local-inference relocation) remains owner-gated work.
