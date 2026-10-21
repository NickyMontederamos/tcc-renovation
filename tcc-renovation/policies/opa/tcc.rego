package slicklab.tcc

# Default-deny. A request is allowed only if it is enabled, its capability is
# enabled, and no deny reason fired. Mirrors the live TCC /mcp/authorize logic:
# unknown/high-impact/unauthorized -> stop before execution.

default allow := false

# The control plane. Heavy/unsafe capabilities must run on workers, never here.
control_plane := "slicklab-vps"

prohibited_on_control_plane := {
  "execute_unknown_binary",
  "heavy-rea",
  "large-local-model",
  "browser-at-scale",
}

deny_reasons contains "unknown binaries are prohibited on the control-plane VPS" if {
  input.action == "execute_unknown_binary"
  input.machine_id == control_plane
}

deny_reasons contains msg if {
  input.machine_id == control_plane
  some cap in input.requested_capabilities
  prohibited_on_control_plane[cap]
  msg := sprintf("capability %q may not be scheduled on the control plane; workers only", [cap])
}

deny_reasons contains "worker-only capability requested on a non-worker machine" if {
  input.capability.placement == "worker-only"
  input.machine_id == control_plane
}

deny_reasons contains "high-risk action requires approval" if {
  input.risk_class == "high"
  not input.approval.granted
}

deny_reasons contains "high-impact MCP tool requires approval" if {
  input.tool_class == "high_impact"
  not input.approval.granted
}

allow if {
  count(deny_reasons) == 0
  input.principal.enabled == true
  input.capability.enabled == true
}
