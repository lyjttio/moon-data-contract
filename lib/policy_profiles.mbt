// Reusable policy profiles and validation helpers for release teams.

///|
pub(all) enum PolicyProfile {
  Development
  Production
  CompatibilityOnly
} derive(Debug, Eq)

///|
pub fn policy_profile_name(profile : PolicyProfile) -> String {
  match profile {
    Development => "development"
    Production => "production"
    CompatibilityOnly => "compatibility-only"
  }
}

///|
fn policy_decision_text(decision : PolicyDecision) -> String {
  match decision {
    Allow => "ALLOW"
    ApprovalRequired => "APPROVAL_REQUIRED"
    Blocked => "BLOCKED"
  }
}

///|
pub fn policy_for_profile(profile : PolicyProfile) -> GovernancePolicy {
  match profile {
    Development => GovernancePolicy::permissive()
    Production => GovernancePolicy::strict()
    CompatibilityOnly =>
      {
        allow_required_additions: true,
        allow_removals: true,
        allow_type_changes: false,
        allow_constraint_changes: false,
        max_risk_score: 35,
        exceptions: [],
      }
  }
}

///|
pub fn GovernancePolicy::with_max_risk_score(
  self : GovernancePolicy,
  score : Int,
) -> GovernancePolicy {
  {
    allow_required_additions: self.allow_required_additions,
    allow_removals: self.allow_removals,
    allow_type_changes: self.allow_type_changes,
    allow_constraint_changes: self.allow_constraint_changes,
    max_risk_score: score,
    exceptions: self.exceptions,
  }
}

///|
pub fn GovernancePolicy::with_type_changes_allowed(
  self : GovernancePolicy,
  allowed : Bool,
) -> GovernancePolicy {
  {
    allow_required_additions: self.allow_required_additions,
    allow_removals: self.allow_removals,
    allow_type_changes: allowed,
    allow_constraint_changes: self.allow_constraint_changes,
    max_risk_score: self.max_risk_score,
    exceptions: self.exceptions,
  }
}

///|
pub fn GovernancePolicy::with_removals_allowed(
  self : GovernancePolicy,
  allowed : Bool,
) -> GovernancePolicy {
  {
    allow_required_additions: self.allow_required_additions,
    allow_removals: allowed,
    allow_type_changes: self.allow_type_changes,
    allow_constraint_changes: self.allow_constraint_changes,
    max_risk_score: self.max_risk_score,
    exceptions: self.exceptions,
  }
}

///|
pub fn policy_validation_errors(policy : GovernancePolicy) -> Array[String] {
  let errors : Array[String] = []
  if policy.max_risk_score < 0 || policy.max_risk_score > 100 {
    errors.push("risk score must be between 0 and 100")
  }
  for exception in policy.exceptions {
    if exception.subject.length() == 0 {
      errors.push("policy exception subject cannot be empty")
    }
    if exception.field_name.length() == 0 {
      errors.push("policy exception field cannot be empty")
    }
    if exception.rule_id.length() == 0 {
      errors.push("policy exception rule cannot be empty")
    }
    if exception.reason.length() == 0 {
      errors.push("policy exception reason cannot be empty")
    }
  }
  errors
}

///|
pub fn GovernancePolicy::is_valid(self : GovernancePolicy) -> Bool {
  policy_validation_errors(self).length() == 0
}

///|
pub fn policy_risk_budget(
  policy : GovernancePolicy,
  findings : Array[PolicyFinding],
) -> Int {
  let mut score = 0
  for finding in findings {
    score += finding.risk_score
  }
  policy.max_risk_score - score
}

///|
pub fn policy_allows_automatic_release(
  policy : GovernancePolicy,
  findings : Array[PolicyFinding],
) -> Bool {
  if !policy.is_valid() {
    return false
  }
  if policy_risk_budget(policy, findings) < 0 {
    return false
  }
  policy_decision(findings) == PolicyDecision::Allow
}

///|
pub fn policy_profile_summary(profile : PolicyProfile) -> String {
  let policy = policy_for_profile(profile)
  policy_profile_name(profile) +
  ": risk<=" +
  policy.max_risk_score.to_string() +
  ", removals=" +
  policy.allow_removals.to_string() +
  ", required_additions=" +
  policy.allow_required_additions.to_string() +
  ", type_changes=" +
  policy.allow_type_changes.to_string()
}
