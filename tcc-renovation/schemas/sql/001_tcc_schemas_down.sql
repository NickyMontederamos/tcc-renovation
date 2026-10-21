-- TCC data foundation — rollback.
--
-- THERE IS NO DESTRUCTIVE DOWN FOR THE LIVE DATABASE HERE, BY DESIGN.
--
-- The live TCC schema lives in `public` and is owned by Alembic. Dropping these tables or
-- the `public` schema would destroy production data (identities, audit_events, memory,
-- promotion history, ...) and is explicitly forbidden by CLAUDE.md
-- ("Never run ... database drop, schema drop ... without exact targeting, approval,
-- backup, and rollback proof").
--
-- To roll back a schema change, use Alembic against the TCC container, e.g.:
--     docker exec deploy-tcc-1 alembic downgrade <target_revision>
-- with a verified backup and an approved CHG-### record (see RB-006 in ROLLBACK_RUNBOOKS.md).
--
-- This file is intentionally a no-op so that a CI harness pairing *_up / *_down cannot
-- accidentally wipe real tables.

BEGIN;
-- no-op: rollback is performed via Alembic, not by dropping public tables.
COMMIT;
