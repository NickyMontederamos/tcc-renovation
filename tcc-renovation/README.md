# SlickLab TCC Renovation

Safe, phased renovation of the SlickLab control plane, Hermes/COLNEX runtime, distributed workers, governed MCP fabric, evidence ledger, REA capability, observability, backup, and security controls.

## Ownership

The infrastructure architecture and all intellectual property in this repository are owned by **SlickLab.Digital**. Proprietary — all rights reserved. See [`LICENSE`](../LICENSE). Niccolo (Nicole) Montederamos is the final human authority on behalf of SlickLab.Digital.

Copyright © 2026 SlickLab.Digital.

## Authority

1. Niccolo is the final human authority.
2. TCC governs missions, policy, approval, evidence, and audit.
3. COLNEX orchestrates.
4. Hermes executes.
5. REA investigates only inside approved worker isolation.

## Current baseline

- Control-plane host: `vmi3585023.contaboserver.net`
- Public IP: `173.249.26.61`
- OS: Ubuntu 24.04.5 LTS
- Capacity: 6 vCPU, 11 GiB RAM
- Audit pressure: load 8.84 and 9.5 GiB of 11 GiB swap used
- Existing critical stack: websites, Hermes, PostgreSQL, pgvector, Redis, LiteLLM, mail/security services, and Docker workloads

## Safety default

All starter scripts are read-only or dry-run by default. Mutation requires an explicit change ID, an approval marker, a verified backup, and `--apply`.

## Start here

1. Read `CLAUDE.md` completely.
2. Run `make preflight`.
3. Run `make audit`.
4. Review generated evidence outside Git.
5. Execute phases in `docs/PHASED_IMPLEMENTATION_PLAN.md` in order.
6. Use `docs/acceptance/ACCEPTANCE_TESTS.md` at every gate.
7. Use `docs/runbooks/ROLLBACK_RUNBOOKS.md` before each production change.

## Important

This repository is scaffolding and an execution contract. It does not authorize direct modification of production and contains no production secrets.
