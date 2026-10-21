# Dependency and Deployment Matrix Summary

| Pillar | Depends on | Placement | Initial state |
|---|---|---|---|
| TCC control plane | PostgreSQL, Redis | VPS | Core after stabilization |
| Hermes/COLNEX | Canonical config, LiteLLM, MCP registry | VPS gateway and workers | Stabilize |
| PostgreSQL/pgvector | Backup and monitoring | VPS | Current/core |
| LiteLLM | Provider secrets and model policy | VPS | Stabilize |
| Governed MCP | TCC policy and capability registry | VPS gateway | Core |
| REA/Ghidra/JADX | Worker enrollment and isolation | Workers only | Static analysis first |
| Playwright/coding workers | Worker isolation and Git worktrees | Workers only | After MCP |
| OpenTelemetry/Prometheus/Grafana | Stable services | Monitoring plane | Core after stabilization |
| Temporal/NATS/Qdrant/memory engines | ADR and benchmark | Separate/deferred | Evaluate |
| Agent Sandbox/gVisor/Kata/Firecracker | Compatible worker infrastructure | Workers only | Evaluate/defer |
