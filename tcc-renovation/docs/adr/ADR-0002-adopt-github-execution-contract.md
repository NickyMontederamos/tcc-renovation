# ADR-0002: Adopt the `tcc-renovation` GitHub repo as the authoritative execution-contract layer

## Status
Approved — 2026-10-21

## Authority
Nicole (Niccolo) Montederamos — final human authority (per ADR-0001 and repo `README.md`).
Adoption and full-automation permission granted to the Claude implementation agent in
session of 2026-10-21.

## Context
ADR-0001 (2026-10-20) adopted **TCC Architecture V1.2** and the
**SlickLab TCC Renovation Execution Handbook v2.0** as the target architecture and primary
renovation standard, and authorized **Phase 0 only**. Execution to date has lived in the
operational workspace `/root/work/tcc-renovation/` (Handbook-numbered phases, with real
secrets, backups, and evidence) and the live control plane at `/root/tcc` (TCC API v0.3.0).

A separate, cleaner **governance + execution-contract repository**
(`github.com/NickyMontederamos/tcc-renovation`) now exists. It is scaffolding and a contract,
not deploy code: `CLAUDE.md` operating loop and controls, a `P0->P10` phased plan, read-only
preflight/audit tooling, an apply-guard requiring `--apply` + `CHANGE_ID` + approval + backup
proof, isolated `tcc_*` SQL migrations, an OPA default-deny policy, inventories, 22 acceptance
tests, 14 rollback runbooks, and ADR/change-record templates.

## Decision
Adopt the GitHub `tcc-renovation` repo as the **authoritative execution-contract and governance
layer** that operationalizes Handbook v2.0. It does **not** replace ADR-0001 or the Handbook:

- **Architecture / target-state authority:** Handbook v2.0 (unchanged; ADR-0001 precedence rules stand).
- **Execution-contract authority:** this GitHub repo's `CLAUDE.md`, phased plan, acceptance
  tests, and rollback runbooks govern *how* every change is made.
- **Evidence precedence:** ADR-0001's "current direct observation outranks documents" rule is retained.

## Reconciliation requirement
The Handbook/local phase numbering and the repo's `P0->P10` numbering differ, and the live TCC
schema design differs from the repo's P4 scaffold. A mapping is maintained at
`docs/evidence/RECONCILIATION-20261021.md` and must be kept current. No phase is considered
"done" under the new structure until its mapped evidence and acceptance tests are recorded there.

## Full-automation scope (what the agent MAY do without further prompting)
- Stand up / maintain this contract repo, its P0 gates, docs, and reconciliation.
- All **read-only** discovery, audit, verification, and acceptance testing.
- Author ADRs, change records, inventories, and staged (inert, reversible) artifacts.

## Still owner-gated (automation does NOT override the contract's own controls)
Every **production mutation** still requires a `CHG-###` change record, approval marker, verified
backup, and a proven rollback — because adopting this contract means *following* it. Specifically
NOT auto-executed: applying the P4 `tcc_*` migration to the live DB (design conflict — see
reconciliation), enabling the P6/local-Phase-5 MCP gate enforcement, worker enrollment (P5),
service restarts, nginx/vhost edits, credential rotation, and all P7–P10 pillars.

## Rollback
Governance-only decision. Reverse by reverting this ADR and the adoption commit; no production
state changes under this ADR. The operational workspace and live control plane are untouched.

## Supersedes / relates to
- Builds on **ADR-0001** (does not supersede it).
- Governs the workspace at `/root/work/tcc-renovation/` and the live control plane `/root/tcc`.
