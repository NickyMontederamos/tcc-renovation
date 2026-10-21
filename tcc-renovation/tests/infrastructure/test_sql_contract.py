from pathlib import Path

def test_tcc_schema_names_are_scoped():
    sql=Path('schemas/sql/001_tcc_schemas_up.sql').read_text()
    for name in ['tcc_control','tcc_registry','tcc_evidence','tcc_policy','tcc_audit']:
        assert name in sql

def test_migration_is_transactional():
    sql=Path('schemas/sql/001_tcc_schemas_up.sql').read_text().strip()
    assert sql.startswith('BEGIN;')
    assert sql.endswith('COMMIT;')
