// Line-oriented evidence summary for shell-based acceptance checks.

///|
pub(all) struct GovernanceAuditSummary {
  subject : String
  lines : Array[String]
  release_allowed : Bool
} derive(Debug, Eq)

///|
pub fn governance_audit_summary(
  result : GovernanceResult,
) -> GovernanceAuditSummary {
  let lines : Array[String] = []
  lines.push("subject=" + result.subject)
  lines.push("status=" + governance_status_text(result.status))
  lines.push("decision=" + policy_decision_text(result.decision))
  lines.push("risk=" + result.risk_score().to_string())
  lines.push("risk_band=" + risk_band_text(result.risk_band()))
  lines.push("transitions=" + result.metrics.transition_count.to_string())
  lines.push("findings=" + result.metrics.finding_count.to_string())
  lines.push("blocking=" + result.metrics.blocking_count.to_string())
  lines.push(
    "automatic_migrations=" + result.metrics.automatic_migrations.to_string(),
  )
  lines.push(
    "manual_migrations=" + result.metrics.manual_migrations.to_string(),
  )
  lines.push("release_allowed=" + result.is_release_allowed().to_string())
  {
    subject: result.subject,
    lines,
    release_allowed: result.is_release_allowed(),
  }
}

///|
pub fn GovernanceAuditSummary::to_text(self : GovernanceAuditSummary) -> String {
  let mut output = ""
  for line in self.lines {
    output = output + line + "\n"
  }
  output
}

///|
pub fn GovernanceAuditSummary::contains_line(
  self : GovernanceAuditSummary,
  prefix : String,
) -> Bool {
  for line in self.lines {
    if line.has_prefix(prefix) {
      return true
    }
  }
  false
}
