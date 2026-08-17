// Policy data types for deterministic contract governance decisions.

///|
pub(all) enum PolicySeverity {
  Info
  Warning
  Error
} derive(Debug, Eq)

///|
pub(all) enum PolicyDecision {
  Allow
  ApprovalRequired
  Blocked
} derive(Debug, Eq)

///|
pub(all) enum PolicyRuleKind {
  OptionalFieldAdded
  RequiredFieldAdded
  FieldRemoved
  TypeChanged
  ConstraintChanged
} derive(Debug, Eq)

///|
pub(all) struct PolicyException {
  subject : String
  field_name : String
  rule_id : String
  reason : String
} derive(Debug, Eq)

///|
pub fn PolicyException::new(
  subject : String,
  field_name : String,
  rule_id : String,
  reason : String,
) -> PolicyException {
  { subject, field_name, rule_id, reason }
}

///|
pub(all) struct GovernancePolicy {
  allow_required_additions : Bool
  allow_removals : Bool
  allow_type_changes : Bool
  allow_constraint_changes : Bool
  max_risk_score : Int
  exceptions : Array[PolicyException]
} derive(Debug, Eq)

///|
pub fn GovernancePolicy::strict() -> GovernancePolicy {
  {
    allow_required_additions: false,
    allow_removals: false,
    allow_type_changes: false,
    allow_constraint_changes: false,
    max_risk_score: 20,
    exceptions: [],
  }
}

///|
pub fn GovernancePolicy::permissive() -> GovernancePolicy {
  {
    allow_required_additions: true,
    allow_removals: true,
    allow_type_changes: true,
    allow_constraint_changes: true,
    max_risk_score: 100,
    exceptions: [],
  }
}

///|
pub fn GovernancePolicy::with_exception(
  self : GovernancePolicy,
  exception : PolicyException,
) -> GovernancePolicy {
  self.exceptions.push(exception)
  self
}

///|
pub(all) struct PolicyFinding {
  rule_id : String
  field_name : String
  severity : PolicySeverity
  blocking : Bool
  exception_applied : Bool
  risk_score : Int
  message : String
} derive(Debug, Eq)
