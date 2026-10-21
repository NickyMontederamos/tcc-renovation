package slicklab.tcc

default allow := false

deny_reasons contains "unknown binaries are prohibited on the control-plane VPS" if {
  input.action == "execute_unknown_binary"
  input.machine_id == "slicklab-vps"
}

deny_reasons contains "high-risk action requires approval" if {
  input.risk_class == "high"
  not input.approval.granted
}

allow if {
  count(deny_reasons) == 0
  input.principal.enabled == true
  input.capability.enabled == true
}
