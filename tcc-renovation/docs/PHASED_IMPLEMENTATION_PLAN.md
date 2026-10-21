# Phased Implementation Plan

## Global gates

A phase passes only when all acceptance tests assigned to it pass, evidence is captured, rollback is proven, and no unresolved severity-1 finding remains.

## P0 - Repository and control contract

### Objective
Create the safe implementation workspace without touching production.

### Build
- Repository layout, branch protection guidance, `.gitignore`, Gitleaks configuration.
- Change-record template, ADR template, machine and service inventory schemas.
- Read-only preflight and audit scripts.

### Dependencies
None.

### Exit gate
- `make preflight` passes locally.
- Secret scan finds no committed credentials.
- Scripts default to read-only/dry-run.

## P1 - Baseline and ownership inventory

### Objective
Reproduce and extend the 2026-10-21 audit with machine-readable evidence.

### Actions
- Inventory system and user units, Docker objects, ports, processes, cron/timers, repositories, databases, schemas, extensions, websites, TLS, firewall, Fail2ban, SSH key fingerprints, Hermes profiles, MCP children, and configuration hashes.
- Record desired owners and replica counts without changing services.
- Resolve whether `113.19.183.185` is authorized before security cleanup.

### Exit gate
- Current state can be reconstructed from `inventory/` and external evidence.
- No secret values are present.
- Unknown ownership is explicitly marked, never guessed.

## P2 - Verified recovery

### Objective
Make every later production change reversible.

### Actions
- Configure off-host Restic for files/config.
- Configure pgBackRest or an equivalent tested PostgreSQL backup path.
- Preserve the approved `hermes_rag` schema and the two Hermes configuration candidates.
- Capture Compose/service definitions and website dependencies.
- Restore backups into isolated locations and run integrity tests.

### Exit gate
- Restore, not merely backup, succeeds.
- PostgreSQL row counts/checksums and pgvector retrieval regression pass.
- Recovery artifacts are encrypted and off-host.

## P3 - Stabilize production

Execute each item as an independent change:

1. `CHG-001`: Telegram credential ownership and routing.
2. `CHG-002`: Telegram path resilience without hardcoding stale IPs.
3. `CHG-003`: canonical Hermes configuration.
4. `CHG-004`: singleton MCP de-duplication.
5. `CHG-005`: browser-controller de-duplication.
6. `CHG-006`: Celery right-sizing from measured queue depth.
7. `CHG-007`: move or cap local inference.
8. `CHG-008`: remove/mask verified legacy failed units.
9. `CHG-009`: investigate and remove or document served token-shaped files.
10. `CHG-010`: remove or correctly configure broken vhosts.
11. `CHG-011`: targeted Docker image/build-cache cleanup.
12. `CHG-012`: clean site-packages contamination from the Hermes Git tree.

### Exit gate
- One token owner per Telegram bot.
- One canonical Hermes config.
- Desired singleton count equals observed count.
- Swap and load are materially improved versus baseline.
- All existing healthy websites remain healthy.

## P4 - TCC data foundation

> **Status 2026-10-21: ALREADY LIVE.** The TCC data foundation is deployed in the `public`
> schema of db `tcc` (container `deploy-postgres-1`, pgvector/pgvector:pg16), owned by
> **Alembic** at head `0010_promotions`. It is a flat `public` design — NOT `tcc_*` namespaced
> schemas. An earlier scaffold draft proposed `tcc_*` schemas; that conflicts with the deployed
> system and must not be applied. `schemas/sql/001_tcc_schemas_up.sql` is now a REFERENCE MIRROR
> of the live schema (idempotent, safe no-op on prod, used to seed CI/staging only).

### Live tables (data contract)
`tasks`, `task_events`, `task_artifacts`, `registry_entities`, `audit_events`, `identities`,
`memory_records`, `memory_candidates` (pgvector), `rag_sources`, `agent_profiles`, `skills`,
`evidence_items`, `validation_runs`, `mcp_tools`, `mcp_call_log`, `promotion_records`.

### Remaining work (validate & reconcile, not re-create)
- Keep `schemas/sql/001_tcc_schemas_up.sql` in sync with Alembic head as the readable contract.
- Any new table/column ships as a new **Alembic** migration in `/root/tcc`, never via this file.
- Schema changes follow RB-006 (Alembic downgrade + verified backup), never a `public` drop.

### Exit gate
- Reference mirror matches Alembic head; applying it to an empty staging DB reproduces the schema.
- No `public` object is dropped to force rollback.
- Every governed mutation writes an `audit_events` row (already enforced live).

## P5 - Worker enrollment and scheduler

### Objective
Make GoldenLegacy, Bobsicles, and approved future nodes managed workers.

### Build
- Machine identity and capability probe.
- Heartbeat and resource reporting.
- Scheduler using capability, load, policy, and concurrency.
- Default scheduling disabled until approval.

### Exit gate
- Machine declarations are derived from probes.
- Worker cannot access production secrets by default.
- Heartbeat loss removes worker from scheduling.

## P6 - Governed MCP fabric

### Objective
Place authentication, authorization, schema validation, timeout, and audit in front of MCP tools.

### Request path
`agent -> TCC policy -> MCP gateway -> registered server -> bounded result -> evidence reference`.

### Exit gate
- Unregistered or unauthorized tools are denied.
- Duplicate singleton registration is rejected.
- Hung tools are terminated.
- Logs redact configured secret fields.

## P7 - REA static-analysis capability

### Objective
Deploy REA only on a worker and begin with harmless static-analysis fixtures.

### Build
- REA worker package.
- Ghidra as initial backend.
- Target hashing, read-only staging, workspace isolation, evidence package.
- Dynamic execution disabled.

### Exit gate
- REA cannot schedule on the VPS.
- Known fixture result is reproducible.
- Evidence separates observation, derivation, inference, and unknown.

## P8 - Browser and coding workers

### Objective
Move browser and coding work off the control plane.

### Build
- One Git worktree per mission.
- Isolated Playwright browser with test accounts.
- Coding-worker adapters with no direct `main` writes.
- Independent test/verification stage.

### Exit gate
- Protected branches cannot be written directly.
- Production credentials are unavailable by default.
- Failed jobs preserve evidence and remove disposable runtime safely.

## P9 - Observability and alerting

### Objective
Make control-plane and worker behavior measurable.

### Build
- OpenTelemetry trace context.
- Prometheus, node exporter, cAdvisor, Grafana.
- Initial alerts for swap, load, backup age, duplicate Telegram token ownership, gateway child-count drift, worker heartbeat, MCP timeout, website/TLS error, evidence-write failure, and unauthorized policy decisions.

### Exit gate
- Mission can be traced across TCC, agent, tool, and worker.
- Metrics endpoints are not public.
- Alert tests generate and resolve correctly.

## P10 - Advanced pillar evaluations

### Objective
Evaluate, never blindly deploy: Temporal, NATS, Qdrant, Mem0, Graphiti, AgentMemory, Keycloak, OpenBao, Agent Sandbox, gVisor, Kata/Firecracker, Langfuse, Loki, Tempo, Forgejo, and Woodpecker.

### Requirement
Each candidate needs an ADR with baseline, benchmark, resource cost, threat model, migration, rollback, and decision.

### Exit gate
Only evidence-backed candidates enter shadow mode. Promotion requires human approval.
