from pathlib import Path

def test_policy_denies_unknown_binary_on_vps():
    text=Path('policies/opa/tcc.rego').read_text()
    assert 'execute_unknown_binary' in text
    assert 'slicklab-vps' in text

def test_default_is_deny():
    assert 'default allow := false' in Path('policies/opa/tcc.rego').read_text()
