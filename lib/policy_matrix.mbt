// Cross-policy compatibility matrix for release planning.

///|
pub(all) struct PolicyMatrixCell {
  profile : PolicyProfile
  level : CompatibilityLevel
  decision : PolicyDecision
  finding_count : Int
  risk_score : Int
  allowed : Bool
} derive(Debug, Eq)

///|
pub(all) struct PolicyMatrixReport {
  cells : Array[PolicyMatrixCell]
  allowed_count : Int
  approval_count : Int
  blocked_count : Int
} derive(Debug, Eq)

///|
fn matrix_profile_text(profile : PolicyProfile) -> String {
  match profile {
    Development => "Development"
    Production => "Production"
    CompatibilityOnly => "CompatibilityOnly"
  }
}

///|
fn matrix_level_text(level : CompatibilityLevel) -> String {
  level.to_string()
}

///|
fn matrix_finding_risk(findings : Array[PolicyFinding]) -> Int {
  let mut risk = 0
  for finding in findings {
    risk += finding.risk_score
  }
  risk
}

///|
pub fn evaluate_policy_matrix(
  base : Schema,
  target : Schema,
  profiles : Array[PolicyProfile],
  levels : Array[CompatibilityLevel],
) -> PolicyMatrixReport {
  let cells : Array[PolicyMatrixCell] = []
  let mut allowed_count = 0
  let mut approval_count = 0
  let mut blocked_count = 0
  for profile in profiles {
    let policy = policy_for_profile(profile)
    for level in levels {
      let findings = evaluate_policy(policy, base, target, level)
      let decision = policy_decision(findings)
      let allowed = policy_allows_automatic_release(policy, findings)
      if allowed {
        allowed_count += 1
      }
      match decision {
        Allow => ()
        ApprovalRequired => approval_count += 1
        Blocked => blocked_count += 1
      }
      cells.push({
        profile,
        level,
        decision,
        finding_count: findings.length(),
        risk_score: matrix_finding_risk(findings),
        allowed,
      })
    }
  }
  { cells, allowed_count, approval_count, blocked_count }
}

///|
pub fn PolicyMatrixReport::to_markdown(self : PolicyMatrixReport) -> String {
  let mut output = "# Policy Compatibility Matrix\n\n"
  output = output + "- Allowed: " + self.allowed_count.to_string() + "\n"
  output = output +
    "- Approval required: " +
    self.approval_count.to_string() +
    "\n"
  output = output + "- Blocked: " + self.blocked_count.to_string() + "\n\n"
  output = output +
    "| Profile | Level | Decision | Findings | Risk | Allowed |\n"
  output = output + "| :--- | :--- | :--- | ---: | ---: | :---: |\n"
  for cell in self.cells {
    output = output +
      "| " +
      matrix_profile_text(cell.profile) +
      " | " +
      matrix_level_text(cell.level) +
      " | " +
      policy_decision_text(cell.decision) +
      " | " +
      cell.finding_count.to_string() +
      " | " +
      cell.risk_score.to_string() +
      " | " +
      cell.allowed.to_string() +
      " |\n"
  }
  output
}

///|
pub fn PolicyMatrixReport::to_json(self : PolicyMatrixReport) -> String {
  let mut output = "{\"allowed_count\":" +
    self.allowed_count.to_string() +
    ",\"approval_count\":" +
    self.approval_count.to_string() +
    ",\"blocked_count\":" +
    self.blocked_count.to_string() +
    ",\"cells\":["
  for i, cell in self.cells {
    if i > 0 {
      output = output + ","
    }
    output = output +
      "{\"profile\":\"" +
      matrix_profile_text(cell.profile) +
      "\",\"level\":\"" +
      matrix_level_text(cell.level) +
      "\",\"decision\":\"" +
      policy_decision_text(cell.decision) +
      "\",\"finding_count\":" +
      cell.finding_count.to_string() +
      ",\"risk_score\":" +
      cell.risk_score.to_string() +
      ",\"allowed\":" +
      cell.allowed.to_string() +
      "}"
  }
  output + "]}"
}
