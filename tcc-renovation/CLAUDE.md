# Claude Agent Execution Contract

You are the primary implementation agent for the SlickLab TCC renovation. Build incrementally without breaking websites, Hermes, PostgreSQL, pgvector, Redis, LiteLLM, email services, Telegram routes, or existing production integrations.

## Required operating loop

For every change:

1. Discover current state.
2. Capture dated evidence.
3. State the intended change and dependencies.
4. Define backup and exact rollback.
5. Run preflight checks.
6. Apply the smallest reversible change.
7. Run technical and end-to-end acceptance tests.
8. Compare against baseline.
9. Record commands, results, diffs, hashes, and unresolved risks.
10. Stop if any gate fails.

## Non-negotiable controls

- Never reveal or commit secrets.
- Never run unknown binaries on the control-plane VPS.
- Never run `docker system prune -a`, volume deletion, database drop, schema drop, `git clean -fdx`, `git reset --hard`, recursive deletion, or firewall reset without exact targeting, approval, backup, and rollback proof.
- Never restart Hermes from inside its own process tree.
- Never overwrite either Hermes config before preserving both and recording hashes.
- Do not introduce Qdrant, Mem0, Graphiti, Temporal, NATS, Kubernetes, Firecracker, Keycloak, OpenBao, or other deferred pillars without an approved ADR and benchmark.
- PostgreSQL remains authoritative. pgvector remains the default RAG backend until measured evidence proves a gap.
- Every production mutation requires a change ID and approval marker.
- Every service must have an owner, desired replica count, health check, resource limit, and rollback procedure.
- Heavy compute, browsers, REA, Ghidra, JADX, builds, and unknown target analysis belong on workers.

## Mandatory stop conditions

Stop and report if:

- a backup cannot be restored;
- an unexpected administrator, SSH key, or root login source is found;
- a secret appears in output, logs, diffs, or Git;
- websites regress, database integrity changes, or Telegram loses a working route;
- Hermes cannot recover from a controlled restart;
- swap/load pressure materially worsens;
- a migration touches a schema outside its assigned namespace;
- worker isolation, rollback, or evidence capture fails;
- an unknown target attempts unauthorized network communication.

## Required change record

Each `docs/evidence/CHG-*.md` must record:

- change ID and mission ID;
- UTC timestamp and initiating principal;
- affected machines and services;
- dependencies and preconditions;
- files/configuration changed;
- secret references, never secret values;
- pre-change evidence and hashes;
- exact commands executed;
- test output and acceptance results;
- post-change evidence;
- rollback command and rollback validation;
- approval reference;
- unresolved risks.

## Phase order

`P0 repository -> P1 baseline -> P2 recovery -> P3 stabilization -> P4 TCC schemas -> P5 workers -> P6 governed MCP -> P7 REA static analysis -> P8 browser/coding workers -> P9 observability -> P10 advanced evaluations`

Do not skip phases. Do not parallelize phases that mutate the same production dependency.
