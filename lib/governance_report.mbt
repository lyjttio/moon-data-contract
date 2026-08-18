// Deterministic Markdown, JSON, and JUnit governance reports.

///|
fn governance_status_text(status : GovernanceStatus) -> String {
  match status {
    Ready => "READY"
    NeedsApproval => "NEEDS_APPROVAL"
    Blocked => "BLOCKED"
  }
}

///|
fn policy_severity_text(severity : PolicySeverity) -> String {
  match severity {
    Info => "INFO"
    Warning => "WARNING"
    Error => "ERROR"
  }
}

///|
pub fn GovernanceResult::to_markdown(self : GovernanceResult) -> String {
  let mut output = "# Contract Governance Report\n\n"
  output = output + "- **Subject**: `" + self.subject + "`\n"
  output = output +
    "- **Status**: " +
    governance_status_text(self.status) +
    "\n"
  output = output + "- **Risk score**: " + self.risk_score().to_string() + "\n"
  output = output +
    "- **Transitions**: " +
    self.metrics.transition_count.to_string() +
    "\n"
  output = output +
    "- **Blocking findings**: " +
    self.metrics.blocking_count.to_string() +
    "\n\n"
  output = output +
    "- **Integrity issues**: " +
    self.metrics.integrity_issue_count.to_string() +
    "\n\n"
  output = output + "## Findings\n\n"
  if self.findings.length() == 0 {
    output = output + "No policy findings.\n\n"
  } else {
    output = output + "| Field | Rule | Severity | Blocking | Evidence |\n"
    output = output + "| :--- | :--- | :--- | :--- | :--- |\n"
    for finding in self.findings {
      output = output +
        "| `" +
        finding.field_name +
        "` | `" +
        finding.rule_id +
        "` | " +
        policy_severity_text(finding.severity) +
        " | " +
        finding.blocking.to_string() +
        " | " +
        finding.message +
        " |\n"
    }
    output = output + "\n"
  }
  output = output + "## Migration plans\n\n"
  if self.migration_plans.length() == 0 {
    output + "No transitions.\n"
  } else {
    for plan in self.migration_plans {
      output = output +
        "- `" +
        plan.base_version +
        "` -> `" +
        plan.target_version +
        "`: " +
        plan.actions.length().to_string() +
        " actions\n"
    }
    output
  }
}

///|
pub fn GovernanceResult::to_json(self : GovernanceResult) -> String {
  let mut output = "{\n"
  output = output + "  \"subject\": \"" + json_escape(self.subject) + "\",\n"
  output = output +
    "  \"status\": \"" +
    governance_status_text(self.status) +
    "\",\n"
  output = output + "  \"risk_score\": " + self.risk_score().to_string() + ",\n"
  output = output + "  \"metrics\": {\n"
  output = output +
    "    \"transition_count\": " +
    self.metrics.transition_count.to_string() +
    ",\n"
  output = output +
    "    \"finding_count\": " +
    self.metrics.finding_count.to_string() +
    ",\n"
  output = output +
    "    \"blocking_count\": " +
    self.metrics.blocking_count.to_string() +
    ",\n"
  output = output +
    "    \"automatic_migrations\": " +
    self.metrics.automatic_migrations.to_string() +
    ",\n"
  output = output +
    "    \"manual_migrations\": " +
    self.metrics.manual_migrations.to_string() +
    "\n"
  output = output + "  },\n  \"findings\": ["
  for i, finding in self.findings {
    if i > 0 {
      output = output + ","
    }
    output = output +
      "{\"rule_id\":\"" +
      json_escape(finding.rule_id) +
      "\",\"field\":\"" +
      json_escape(finding.field_name) +
      "\",\"severity\":\"" +
      policy_severity_text(finding.severity) +
      "\",\"blocking\":" +
      finding.blocking.to_string() +
      ",\"exception_applied\":" +
      finding.exception_applied.to_string() +
      ",\"risk_score\":" +
      finding.risk_score.to_string() +
      ",\"message\":\"" +
      json_escape(finding.message) +
      "}"
  }
  output = output + "],\n  \"migration_plans\": ["
  for i, plan in self.migration_plans {
    if i > 0 {
      output = output + ","
    }
    output = output +
      "{\"base_version\":\"" +
      json_escape(plan.base_version) +
      "\",\"target_version\":\"" +
      json_escape(plan.target_version) +
      "\",\"actions\":["
    for j, action in plan.actions {
      if j > 0 {
        output = output + ","
      }
      output = output +
        "{\"field\":\"" +
        json_escape(action.field_name) +
        "\",\"kind\":\"" +
        migration_kind_text(action.kind) +
        "\",\"safety\":\"" +
        migration_safety_text(action.safety) +
        "\",\"reversible\":" +
        action.reversible.to_string() +
        ",\"reason\":\"" +
        json_escape(action.reason) +
        "\"}"
    }
    output = output + "]}"
  }
  output + "]\n}"
}

///|
pub fn GovernanceResult::to_junit(self : GovernanceResult) -> String {
  let reportable : Array[PolicyFinding] = []
  for finding in self.findings {
    match finding.severity {
      Info => ()
      Warning | Error => reportable.push(finding)
    }
  }
  let mut failures = 0
  for finding in reportable {
    if finding.blocking {
      failures = failures + 1
    }
  }
  let mut output = "<testsuite name=\"contract-governance\" tests=\"" +
    reportable.length().to_string() +
    "\" failures=\"" +
    failures.to_string() +
    "\">"
  for finding in reportable {
    output = output +
      "<testcase name=\"" +
      xml_escape(finding.rule_id + ":" + finding.field_name) +
      "\">"
    if finding.blocking {
      output = output +
        "<failure message=\"" +
        xml_escape(finding.message) +
        "\"/>"
    } else {
      output = output +
        "<system-out>" +
        xml_escape(finding.message) +
        "</system-out>"
    }
    output = output + "</testcase>"
  }
  output + "</testsuite>"
}
