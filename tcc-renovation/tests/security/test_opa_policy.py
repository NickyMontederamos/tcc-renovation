from pathlib import Path

POLICY = Path('policies/opa/tcc.rego').read_text()


def test_policy_denies_unknown_binary_on_vps():
    assert 'execute_unknown_binary' in POLICY
    assert 'slicklab-vps' in POLICY


def test_default_is_deny():
    assert 'default allow := false' in POLICY


def test_control_plane_prohibitions_present():
    # The control plane must refuse heavy/worker-only capabilities.
    for cap in ['heavy-rea', 'large-local-model', 'browser-at-scale']:
        assert cap in POLICY
    assert 'worker-only' in POLICY


def test_high_impact_requires_approval():
    assert 'high_impact' in POLICY
    assert 'approval' in POLICY
