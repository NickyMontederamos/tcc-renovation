# Detailed Acceptance Tests

## Test execution rules

- Run pre-change and post-change.
- Store raw output outside Git; store redacted summaries and hashes in `docs/evidence/`.
- A failed critical test blocks promotion.
- Never convert a failed test into a warning merely to continue.

## AT-001 Website availability and TLS

**Purpose:** prove renovation did not regress existing public sites.

**Procedure:**
1. Read expected URLs/statuses from `inventory/web-endpoints.example.yml`.
2. Resolve DNS and record destination.
3. Request each endpoint with redirect capture, timeout, and TLS verification.
4. Record status, final URL, certificate subject/SAN/expiry, TTFB, and total time.
5. Compare to baseline.

**Pass:** expected status/redirect is preserved; certificate validates; no new 5xx; latency does not exceed the configured regression threshold.

**Rollback trigger:** any critical endpoint fails twice from separate probes after known transient causes are excluded.

## AT-002 PostgreSQL backup and restore

**Procedure:**
1. Create backup with documented tool/version.
2. Record backup manifest and SHA-256.
3. Restore to isolated database/server.
4. Compare database/schema inventories, extension versions, critical table counts, and selected checksums.
5. Run application read-only smoke queries.

**Pass:** restore completes with no corruption; expected schemas and extensions exist; counts/checksums match accepted variance.

## AT-003 pgvector retrieval regression

**Procedure:**
1. Use a versioned fixed query set against approved-only corpus.
2. Capture top-k document/chunk IDs and scores before change.
3. Repeat after change with the same embedding model/version and parameters.
4. Verify no pending/rejected/untrusted rows appear.

**Pass:** approved-only isolation remains intact and top-k relevance stays inside the declared tolerance.

## AT-004 Hermes canonical configuration

**Procedure:**
1. Hash canonical config and rendered runtime config.
2. Query gateway status and process environment without exposing secret values.
3. Verify model default, max turns, reasoning effort, memory limit, MCP set, concurrency, and cache TTL.
4. Restart from an external supervisor process only.
5. Repeat checks.

**Pass:** one authoritative source renders the running configuration; restart preserves behavior; no stale second config is independently edited.

## AT-005 Telegram credential ownership and round trip

**Procedure:**
1. Compare token fingerprints, never values, across profiles.
2. Assert each fingerprint has exactly one adapter owner.
3. Send a controlled test message to each active bot.
4. Confirm one response and one processing trace.
5. Verify no `getUpdates` collision or parked-adapter warning.

**Pass:** exactly one owner per credential and successful round trip.

## AT-006 Singleton process count

**Procedure:**
1. Load desired replicas from `inventory/services.yml`.
2. Count systemd, user-unit, Docker, PM2, and child-process copies.
3. Map observed PID/container to registered service owner.

**Pass:** observed equals desired for all singleton services; no unregistered duplicate listeners.

## AT-007 Host saturation

**Procedure:**
1. Collect load, run queue, memory, swap used, swap-in/out, CPU steal, and top process RSS/swap.
2. Observe at multiple intervals under idle and a controlled normal workload.
3. Compare with 2026-10-21 baseline.

**Pass:** sustained load does not exceed CPU count under idle conditions; swap use and active swap I/O are materially improved; no control service is OOM-killed.

## AT-008 TCC schema isolation

**Procedure:**
1. Snapshot PostgreSQL object inventory.
2. Apply migration.
3. Diff objects and privileges.
4. Roll back in staging and diff again.

**Pass:** only `tcc_*` namespaces and explicitly approved roles change; rollback restores prior inventory.

## AT-009 Audit completeness

**Procedure:** create one test mission, job, policy decision, approval, evidence record, and completion event.

**Pass:** all records share mission/job/trace identifiers, timestamps, actor identity, and integrity metadata.

## AT-010 Worker enrollment and heartbeat

**Procedure:**
1. Enroll worker with scheduling disabled.
2. Run capability probes.
3. Approve and enable one low-risk job.
4. Stop heartbeat.

**Pass:** discovered resources are stored; low-risk job runs; heartbeat loss prevents new scheduling.

## AT-011 Worker secret isolation

**Procedure:** from a test job, attempt to enumerate environment, secret mounts, host paths, cloud metadata, and unrelated service credentials.

**Pass:** only explicitly scoped test secrets are available; access attempts are denied and audited.

## AT-012 MCP authorization

**Procedure:** invoke registered tool with allowed principal, denied principal, malformed schema, expired identity, and unregistered tool name.

**Pass:** only allowed and valid request executes; all decisions are audited.

## AT-013 MCP timeout and cleanup

**Procedure:** invoke a fixture server that hangs and spawns a child.

**Pass:** timeout terminates parent and child, releases port/resources, and records bounded failure.

## AT-014 REA static-analysis reproducibility

**Procedure:**
1. Hash a harmless fixture binary whose behavior is known.
2. Stage read-only on worker.
3. Run REA with pinned backend/tool versions.
4. Repeat in a fresh workspace.

**Pass:** evidence references the same target hash; core observations match; no dynamic execution occurs; unresolved uncertainty is recorded.

## AT-015 Unknown-target network denial

**Procedure:** execute only an approved network-test fixture in the intended high-risk sandbox and attempt blocked egress destinations.

**Pass:** egress is blocked by policy, event is logged, and control-plane access is impossible.

## AT-016 Git worktree isolation

**Procedure:** create two jobs against one repository, modify the same test file differently, and attempt direct protected-branch push.

**Pass:** changes remain isolated; protected branch rejects direct push; each job yields an independent diff.

## AT-017 Browser worker isolation

**Procedure:** launch an isolated browser, use a test account, capture screenshot, then destroy runtime.

**Pass:** session completes, storage is scoped to job, production cookies are absent, and job cleanup removes disposable state.

## AT-018 LiteLLM policy and fallback

**Procedure:** test allowed model, denied model, provider timeout, budget exceeded, and fallback.

**Pass:** policy is enforced; fallback follows declared order; prompt content is not logged when disabled.

## AT-019 Observability trace continuity

**Procedure:** execute a fixture mission through TCC, Hermes, MCP, worker, and evidence write.

**Pass:** one trace links every hop with mission/job/agent/machine/tool/model identifiers.

## AT-020 Alert verification

**Procedure:** generate safe synthetic conditions for stale heartbeat, MCP timeout, failed website fixture, and stale backup marker.

**Pass:** alert fires, routes correctly, deduplicates, and resolves after recovery.

## AT-021 Supply-chain gate

**Procedure:** run tests, Gitleaks, Syft, Trivy/Grype, and signature verification on fixture release.

**Pass:** no secret; blocking severity policy enforced; SBOM attached; signature verifies.

## AT-022 Rollback rehearsal

**Procedure:** deploy a reversible fixture version, validate, roll back using the documented runbook, and validate again.

**Pass:** previous version and data compatibility are restored within the documented procedure, with no evidence loss.
