BEGIN;
CREATE SCHEMA IF NOT EXISTS tcc_control;
CREATE SCHEMA IF NOT EXISTS tcc_registry;
CREATE SCHEMA IF NOT EXISTS tcc_evidence;
CREATE SCHEMA IF NOT EXISTS tcc_policy;
CREATE SCHEMA IF NOT EXISTS tcc_audit;

CREATE TABLE IF NOT EXISTS tcc_registry.machines (
  machine_id text PRIMARY KEY,
  display_name text NOT NULL,
  roles jsonb NOT NULL DEFAULT '[]',
  capabilities jsonb NOT NULL DEFAULT '{}',
  scheduling_enabled boolean NOT NULL DEFAULT false,
  last_heartbeat_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS tcc_registry.agents (
  agent_id text PRIMARY KEY,
  display_name text NOT NULL,
  runtime text NOT NULL,
  permissions jsonb NOT NULL DEFAULT '{}',
  enabled boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS tcc_registry.capabilities (
  capability_id text PRIMARY KEY,
  owner text NOT NULL,
  placement_policy text NOT NULL,
  desired_replicas integer NOT NULL DEFAULT 0 CHECK (desired_replicas >= 0),
  risk_class text NOT NULL,
  config jsonb NOT NULL DEFAULT '{}',
  enabled boolean NOT NULL DEFAULT false
);

CREATE TABLE IF NOT EXISTS tcc_control.missions (
  mission_id uuid PRIMARY KEY,
  title text NOT NULL,
  requested_by text NOT NULL,
  status text NOT NULL,
  risk_class text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS tcc_control.jobs (
  job_id uuid PRIMARY KEY,
  mission_id uuid NOT NULL REFERENCES tcc_control.missions(mission_id),
  assigned_agent text REFERENCES tcc_registry.agents(agent_id),
  assigned_machine text REFERENCES tcc_registry.machines(machine_id),
  status text NOT NULL,
  requirements jsonb NOT NULL DEFAULT '{}',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS tcc_evidence.artifacts (
  artifact_id uuid PRIMARY KEY,
  mission_id uuid REFERENCES tcc_control.missions(mission_id),
  sha256 text NOT NULL CHECK (sha256 ~ '^[0-9a-f]{64}$'),
  size_bytes bigint NOT NULL CHECK (size_bytes >= 0),
  mime_type text,
  object_ref text NOT NULL,
  classification text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS tcc_evidence.claims (
  claim_id uuid PRIMARY KEY,
  mission_id uuid NOT NULL REFERENCES tcc_control.missions(mission_id),
  claim_type text NOT NULL CHECK (claim_type IN ('observation','derivation','inference','unknown')),
  statement text NOT NULL,
  confidence numeric CHECK (confidence IS NULL OR (confidence >= 0 AND confidence <= 1)),
  provenance jsonb NOT NULL DEFAULT '{}',
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS tcc_policy.approvals (
  approval_id uuid PRIMARY KEY,
  mission_id uuid NOT NULL REFERENCES tcc_control.missions(mission_id),
  action text NOT NULL,
  requested_from text NOT NULL,
  status text NOT NULL,
  decided_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS tcc_audit.events (
  event_id uuid PRIMARY KEY,
  mission_id uuid,
  job_id uuid,
  trace_id text,
  actor text NOT NULL,
  action text NOT NULL,
  outcome text NOT NULL,
  metadata jsonb NOT NULL DEFAULT '{}',
  created_at timestamptz NOT NULL DEFAULT now()
);
COMMIT;
