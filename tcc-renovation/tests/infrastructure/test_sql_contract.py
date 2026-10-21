from pathlib import Path

UP = Path('schemas/sql/001_tcc_schemas_up.sql')
DOWN = Path('schemas/sql/001_tcc_schemas_down.sql')

LIVE_TABLES = [
    'tasks', 'task_events', 'task_artifacts', 'registry_entities', 'audit_events',
    'identities', 'memory_records', 'memory_candidates', 'rag_sources',
    'agent_profiles', 'skills', 'evidence_items', 'validation_runs',
    'mcp_tools', 'mcp_call_log', 'promotion_records',
]


def test_reference_mirror_has_every_live_table():
    sql = UP.read_text()
    for t in LIVE_TABLES:
        assert f'CREATE TABLE IF NOT EXISTS {t} ' in sql, f'missing live table: {t}'


def test_reference_mirror_is_idempotent():
    # Every CREATE TABLE must be IF NOT EXISTS so running against the live DB is a no-op.
    sql = UP.read_text().lower()
    assert 'create table ' in sql
    assert sql.count('create table if not exists') == sql.count('create table ')


def test_reference_mirror_is_transactional():
    sql = UP.read_text().strip()
    assert sql.startswith('BEGIN;') or sql.splitlines()[0].startswith('--')
    assert sql.rstrip().endswith('COMMIT;')


def test_no_fictional_tcc_star_schemas():
    # Guard against regressing to the conflicting tcc_* design.
    sql = UP.read_text()
    for bad in ['tcc_control', 'tcc_registry', 'tcc_evidence', 'tcc_policy', 'tcc_audit']:
        assert bad not in sql, f'fictional schema reintroduced: {bad}'


def test_pgvector_declared():
    assert 'CREATE EXTENSION IF NOT EXISTS vector' in UP.read_text()


def test_down_never_drops_public():
    # Rollback is via Alembic; the down file must not drop tables or the public schema.
    down = DOWN.read_text().lower()
    assert 'drop table' not in down
    assert 'drop schema' not in down
