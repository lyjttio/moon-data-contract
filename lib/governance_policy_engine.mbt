// Policy evaluation over the existing Schema Diff and compatibility engines.

///|
fn policy_finding_before(left : PolicyFinding, right : PolicyFinding) -> Bool {
  if left.field_name != right.field_name {
    left.field_name < right.field_name
  } else {
    left.rule_id < right.rule_id
  }
}

///|
fn sorted_policy_findings(
  findings : Array[PolicyFinding],
) -> Array[PolicyFinding] {
  let sorted : Array[PolicyFinding] = []
  for finding in findings {
    let next : Array[PolicyFinding] = []
    let mut inserted = false
    for existing in sorted {
      if !inserted && policy_finding_before(finding, existing) {
        next.push(finding)
        inserted = true
      }
      next.push(existing)
    }
    if !inserted {
      next.push(finding)
    }
    sorted.clear()
    for item in next {
      sorted.push(item)
    }
  }
  sorted
}

///|
fn exception_for(
  policy : GovernancePolicy,
  subject : String,
  field_name : String,
  rule_id : String,
) -> Bool {
  for exception in policy.exceptions {
    if exception.subject == subject &&
      exception.field_name == field_name &&
      exception.rule_id == rule_id {
      return true
    }
  }
  false
}

///|
fn finding_for_diff(
  policy : GovernancePolicy,
  subject : String,
  diff : DiffEntry,
) -> PolicyFinding {
  let (rule_id, risk_score, severity, default_blocking) = match diff.kind {
    FieldAdded(field) =>
      if field.required {
        ("required-field-added", 10, Error, !policy.allow_required_additions)
      } else {
        ("optional-field-added", 1, Info, false)
      }
    FieldRemoved(_) => ("field-removed", 10, Error, !policy.allow_removals)
    TypeChanged(_, _) =>
      ("type-changed", 8, Warning, !policy.allow_type_changes)
    RequiredChanged(_, required) =>
      if required {
        ("required-field-added", 10, Error, !policy.allow_required_additions)
      } else {
        ("required-field-relaxed", 2, Info, false)
      }
    ConstraintChanged(_, _) =>
      ("constraint-changed", 5, Warning, !policy.allow_constraint_changes)
  }
  let exception_applied = exception_for(
    policy,
    subject,
    diff.field_name,
    rule_id,
  )
  {
    rule_id,
    field_name: diff.field_name,
    severity,
    blocking: default_blocking && !exception_applied,
    exception_applied,
    risk_score,
    message: diff.description,
  }
}

///|
pub fn evaluate_policy(
  policy : GovernancePolicy,
  base : Schema,
  target : Schema,
  level : CompatibilityLevel,
) -> Array[PolicyFinding] {
  let compatibility = check_compatibility(base, target, level)
  let findings : Array[PolicyFinding] = []
  for diff in compatibility.diffs {
    findings.push(finding_for_diff(policy, base.id, diff))
  }
  sorted_policy_findings(findings)
}

///|
pub fn policy_decision(findings : Array[PolicyFinding]) -> PolicyDecision {
  let mut has_warning = false
  for finding in findings {
    if finding.blocking {
      return Blocked
    }
    if finding.severity == Warning {
      has_warning = true
    }
  }
  if has_warning {
    ApprovalRequired
  } else {
    Allow
  }
}
