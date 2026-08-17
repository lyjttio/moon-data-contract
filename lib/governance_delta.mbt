// Stable comparison of governance evidence between two evaluations.

///|
pub(all) struct GovernanceDelta {
  subject : String
  status_changed : Bool
  previous_risk_score : Int
  current_risk_score : Int
  risk_delta : Int
  previous_transition_count : Int
  current_transition_count : Int
  new_finding_count : Int
  resolved_finding_count : Int
  new_blocking_count : Int
} derive(Debug, Eq)

///|
fn same_finding(left : PolicyFinding, right : PolicyFinding) -> Bool {
  left.rule_id == right.rule_id && left.field_name == right.field_name
}

///|
fn finding_in(findings : Array[PolicyFinding], target : PolicyFinding) -> Bool {
  for finding in findings {
    if same_finding(finding, target) {
      return true
    }
  }
  false
}

///|
pub fn compare_governance_results(
  previous : GovernanceResult,
  current : GovernanceResult,
) -> GovernanceDelta {
  let mut new_finding_count = 0
  let mut new_blocking_count = 0
  for finding in current.findings {
    if !finding_in(previous.findings, finding) {
      new_finding_count += 1
      if finding.blocking {
        new_blocking_count += 1
      }
    }
  }
  let mut resolved_finding_count = 0
  for finding in previous.findings {
    if !finding_in(current.findings, finding) {
      resolved_finding_count += 1
    }
  }
  {
    subject: current.subject,
    status_changed: previous.status != current.status,
    previous_risk_score: previous.risk_score(),
    current_risk_score: current.risk_score(),
    risk_delta: current.risk_score() - previous.risk_score(),
    previous_transition_count: previous.metrics.transition_count,
    current_transition_count: current.metrics.transition_count,
    new_finding_count,
    resolved_finding_count,
    new_blocking_count,
  }
}

///|
pub fn GovernanceDelta::is_regression(self : GovernanceDelta) -> Bool {
  self.risk_delta > 0 || self.new_blocking_count > 0
}

///|
pub fn GovernanceDelta::summary(self : GovernanceDelta) -> String {
  "subject=" +
  self.subject +
  ", risk_delta=" +
  self.risk_delta.to_string() +
  ", new_findings=" +
  self.new_finding_count.to_string() +
  ", resolved_findings=" +
  self.resolved_finding_count.to_string() +
  ", regression=" +
  self.is_regression().to_string()
}
