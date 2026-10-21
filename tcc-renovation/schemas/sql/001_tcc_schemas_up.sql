-- TCC data foundation — REFERENCE MIRROR of the LIVE schema.
--
-- Authoritative source of truth: Alembic migrations in /root/tcc (head: 0010_promotions).
-- This file MIRRORS the deployed schema so it can be (a) read as the data contract and
-- (b) applied idempotently to an EMPTY staging/CI database for acceptance tests.
--
-- The live TCC data foundation already exists in the `public` schema of db `tcc`
-- (container deploy-postgres-1, image pgvector/pgvector:pg16). It is NOT a set of
-- `tcc_*` namespaced schemas — earlier scaffold drafts proposed that and were WRONG for
-- this architecture. Do not create parallel `tcc_*` schemas.
--
-- Safety: every statement is CREATE ... IF NOT EXISTS, so running this against the live
-- database is a no-op. NEVER hand-edit live structure with this file; change the schema
-- only through Alembic. pgvector is required (memory_candidates.embedding).

BEGIN;
CREATE EXTENSION IF NOT EXISTS vector;

-- Contract / task plane -----------------------------------------------------
CREATE TABLE IF NOT EXISTS tasks (
  contract_id   varchar PRIMARY KEY,
  state         varchar NOT NULL,
  contract_json json    NOT NULL,
  created_at    timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS task_events (
  id           serial PRIMARY KEY,
  contract_id  varchar NOT NULL,
  from_state   varchar,
  to_state     varchar,
  actor        varchar,
  reason       varchar,
  occurred_at  timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS task_artifacts (
  id            serial PRIMARY KEY,
  contract_id   varchar NOT NULL,
  kind          varchar NOT NULL,
  artifact_json json    NOT NULL,
  created_at    timestamptz NOT NULL DEFAULT now()
);

-- Registry (every live service + agent) -------------------------------------
CREATE TABLE IF NOT EXISTS registry_entities (
  id          serial PRIMARY KEY,
  kind        varchar NOT NULL,
  entity_id   varchar NOT NULL,
  name        varchar,
  status      varchar,
  source      varchar,
  data_json   json,
  observed_at timestamptz NOT NULL DEFAULT now()
);

-- Audit (append-only, hash-chained payloads) --------------------------------
CREATE TABLE IF NOT EXISTS audit_events (
  id             serial PRIMARY KEY,
  occurred_at    timestamptz NOT NULL DEFAULT now(),
  actor          varchar NOT NULL,
  action         varchar NOT NULL,
  target         varchar,
  detail_json    json,
  payload_sha256 varchar
);

-- Identity & least-privilege scopes -----------------------------------------
CREATE TABLE IF NOT EXISTS identities (
  identity_id  varchar PRIMARY KEY,
  kind         varchar NOT NULL,
  name         varchar NOT NULL,
  status       varchar NOT NULL,
  token_sha256 varchar NOT NULL,          -- hash only, never the token
  scopes       json    NOT NULL DEFAULT '[]',
  created_at   timestamptz NOT NULL DEFAULT now(),
  expires_at   timestamptz,
  revoked_at   timestamptz
);

-- Governed memory -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS memory_records (
  mem_id         varchar PRIMARY KEY,
  mem_class      varchar NOT NULL,        -- scratch|episodic|project|procedural|long_term
  key            varchar,
  content        varchar,
  content_sha256 varchar,
  source         varchar,
  confidence     varchar,
  scope          varchar,
  state          varchar NOT NULL,        -- proposed|verified|approved|conflict|superseded
  proposed_by    varchar,
  verified_by    varchar,
  approved_by    varchar,
  created_at     timestamptz NOT NULL DEFAULT now(),
  updated_at     timestamptz NOT NULL DEFAULT now(),
  expires_at     timestamptz
);
CREATE TABLE IF NOT EXISTS memory_candidates (
  candidate_id   varchar PRIMARY KEY,
  contract_id    varchar,
  candidate_json json,
  embedding      vector                   -- pgvector; default RAG backend
);

-- Governed RAG corpus (approved-only retrieval) -----------------------------
CREATE TABLE IF NOT EXISTS rag_sources (
  source_id      varchar PRIMARY KEY,
  name           varchar,
  uri            varchar,
  scope          varchar,
  state          varchar,                 -- approved-only is returned at query time
  content_sha256 varchar,
  added_by       varchar,
  approved_by    varchar,
  created_at     timestamptz NOT NULL DEFAULT now(),
  updated_at     timestamptz NOT NULL DEFAULT now()
);

-- Agent & skill registry ----------------------------------------------------
CREATE TABLE IF NOT EXISTS agent_profiles (
  agent_id       varchar PRIMARY KEY,
  owner          varchar,
  purpose        varchar,
  allowed_tools  json,
  allowed_memory json,
  risk_tier      varchar,                 -- quarantined/disabled/unknown cannot receive work
  status         varchar,
  tests_ref      varchar,
  created_at     timestamptz NOT NULL DEFAULT now(),
  updated_at     timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS skills (
  skill_id      varchar PRIMARY KEY,
  name          varchar,
  version       varchar,
  input_schema  json,
  output_schema json,
  workflow      json,
  created_by    varchar,
  created_at    timestamptz NOT NULL DEFAULT now()
);

-- Evidence & validation plane -----------------------------------------------
CREATE TABLE IF NOT EXISTS evidence_items (
  evidence_id   varchar PRIMARY KEY,
  contract_id   varchar,
  evidence_json json
);
CREATE TABLE IF NOT EXISTS validation_runs (
  run_id         varchar PRIMARY KEY,
  job_type       varchar,
  target         varchar,
  status         varchar,                 -- promotion is gated on a passed run
  manifest       json,
  reasons        json,
  evidence_sha256 varchar,                -- manifest hash = tamper-evident
  validated_by   varchar,
  created_at     timestamptz NOT NULL DEFAULT now()
);

-- Governed MCP fabric -------------------------------------------------------
CREATE TABLE IF NOT EXISTS mcp_tools (
  tool_id            varchar PRIMARY KEY,
  server             varchar,
  name               varchar,
  tool_class         varchar,             -- read_only|reversible|high_impact
  arg_schema         json,
  rate_limit_per_min integer,
  required_scope     varchar,
  enabled            boolean NOT NULL DEFAULT false,
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS mcp_call_log (
  id          serial PRIMARY KEY,
  identity_id varchar,
  tool_id     varchar,
  args_sha256 varchar,
  decision    varchar,                    -- allow|deny|needs_approval
  reason      varchar,
  created_at  timestamptz NOT NULL DEFAULT now()
);

-- Promotion / change-safety plane -------------------------------------------
CREATE TABLE IF NOT EXISTS promotion_records (
  promo_id          varchar PRIMARY KEY,
  target            varchar,
  from_ref          varchar,
  to_ref            varchar,
  status            varchar,              -- blocked without validation + rollback_ref
  validation_run_id varchar,
  pre_check         json,
  post_check        json,
  rollback_ref      varchar,
  requested_by      varchar,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now()
);
COMMIT;
