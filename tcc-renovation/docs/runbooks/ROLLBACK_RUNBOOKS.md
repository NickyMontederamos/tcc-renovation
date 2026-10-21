# Rollback Runbooks

## Universal rollback protocol

1. Stop new scheduling for the affected capability.
2. Preserve logs, traces, process lists, config hashes, database state, and current artifact hashes.
3. Announce rollback state in the change record.
4. Execute the exact pre-tested rollback for the affected component.
5. Validate dependencies from the bottom up: storage, database, queue, service, gateway, public path.
6. Run the assigned acceptance tests.
7. Re-enable traffic gradually.
8. Record whether rollback fully restored the baseline.

Do not delete failed-state evidence until incident review is complete.

## RB-001 Hermes configuration rollback

**Trigger:** gateway fails, adapters disappear, model/tool behavior differs unexpectedly, or memory rises materially.

**Preconditions:** preserved canonical and prior configs with SHA-256; external supervisor shell remains available.

**Steps:**
1. Freeze scheduled Hermes jobs.
2. Copy current failing config to evidence storage.
3. Restore prior config atomically through a temporary file and rename.
4. Validate YAML syntax and file permissions.
5. Restart gateway from the external supervisor.
6. Run AT-004 and AT-005.
7. Unfreeze jobs only after pass.

## RB-002 Telegram routing rollback

**Trigger:** active bot stops receiving, duplicate polling appears, or wrong profile handles messages.

**Steps:**
1. Disable only the newly changed adapter/route.
2. Restore previous route map and credential reference, not raw token text.
3. Ensure exactly one adapter owns the token fingerprint.
4. Restart gateway externally.
5. Run controlled round trip for each active bot.

## RB-003 MCP singleton rollback

**Trigger:** tool unavailable, child leak, port conflict, or error-rate regression.

**Steps:**
1. Remove new MCP gateway route from scheduling.
2. Stop the new singleton instance.
3. Restore prior registered instance/service definition.
4. Verify only one listener and expected child tree.
5. Execute authorization and timeout tests.

## RB-004 Celery right-sizing rollback

**Trigger:** queue age/backlog exceeds approved threshold or critical task latency regresses.

**Steps:**
1. Capture queue depth and active/reserved task state.
2. Increase concurrency to the last known safe value, not automatically to 22.
3. Avoid terminating active non-idempotent tasks.
4. Validate queue drain and host pressure.

## RB-005 Local-model relocation rollback

**Trigger:** remote inference unavailable or unacceptable fallback failure.

**Steps:**
1. Route affected model class to approved cloud fallback or last known worker.
2. Re-enable VPS emergency model only with documented thread/context/memory caps.
3. Confirm control-plane swap and load remain inside guardrails.
4. Disable emergency model after worker recovery.

## RB-006 PostgreSQL migration rollback

**Trigger:** migration fails, touches unauthorized schema, breaks queries, or violates integrity.

**Steps:**
1. Stop application writes for affected TCC component.
2. Capture failure evidence and migration version.
3. Run tested down migration only if transaction and compatibility conditions permit.
4. Otherwise restore to isolated replacement and perform controlled cutback.
5. Never drop broad schemas to force rollback.
6. Run AT-002, AT-003, and AT-008.

## RB-007 Worker enrollment rollback

**Trigger:** worker exposes secrets, reports false capabilities, or destabilizes network/control plane.

**Steps:**
1. Disable scheduling for machine ID.
2. Revoke worker credential/certificate.
3. Terminate active disposable jobs safely.
4. Preserve job evidence.
5. Remove routes/firewall grants added for enrollment.
6. Verify worker cannot call control APIs.

## RB-008 Governed MCP rollout rollback

**Trigger:** gateway blocks legitimate critical operations or bypass is discovered.

**Steps:**
1. Freeze nonessential tool calls.
2. Restore the previous approved direct path only for explicitly listed critical tools.
3. Keep auditing around the temporary path.
4. Revert gateway config/package to prior signed version.
5. Execute AT-012 and AT-013 before resuming migration.

## RB-009 REA deployment rollback

**Trigger:** worker instability, unexpected execution, network escape, or evidence corruption.

**Steps:**
1. Disable REA capability in registry.
2. Terminate sandbox and preserve disk image/logs if safe.
3. Revoke target workspace access.
4. Remove worker package/container by exact version.
5. Verify control plane and worker have no residual listener/process.
6. Keep targets quarantined until review.

## RB-010 Browser/coding worker rollback

**Trigger:** credential exposure, branch protection bypass, persistent session leak, or bad production mutation.

**Steps:**
1. Disable worker capability and revoke scoped credentials.
2. Preserve worktree diff, browser trace, screenshots, and logs.
3. Destroy disposable runtime.
4. Revert application change using Git revert or previously tested deployment rollback.
5. Re-run website and integration tests.

## RB-011 Observability rollback

**Trigger:** telemetry causes resource pressure, leaks secrets, or blocks services.

**Steps:**
1. Disable exporters/collectors with the highest measured impact.
2. Restore prior service configuration.
3. Preserve telemetry config and redacted samples.
4. Confirm application health independently of monitoring.
5. Keep minimum host metrics if safe.

## RB-012 Website/vhost rollback

**Trigger:** 4xx/5xx regression, redirect loop, TLS failure, or wrong docroot.

**Steps:**
1. Restore previous versioned Nginx/vhost config.
2. Run syntax test before reload.
3. Reload, do not restart, when supported.
4. Verify DNS, status, redirect target, docroot, and certificate.
5. Restore prior files from tested backup if content changed.

## RB-013 Docker cleanup rollback limitation

Image/cache cleanup is not inherently reversible. Therefore:
- Never remove an image unless its immutable digest exists in a registry or export archive.
- Never remove a volume under a cleanup change.
- Record image digests before cleanup.
- Recovery means pulling/importing exact digests and recreating containers from versioned Compose.

## RB-014 Firewall/security rollback

**Trigger:** management lockout or service outage.

**Steps:**
1. Keep a separate confirmed administrative session open before change.
2. Export current rules.
3. Apply one rule set atomically with an automatic rollback timer where possible.
4. Verify SSH over approved paths and public website access.
5. Cancel rollback timer only after pass.
