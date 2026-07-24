// MoonBit Data Contract - Field Rules & Metadata System

///|
pub(all) enum RuleSeverity {
  SeverityInfo
  SeverityWarning
  SeverityError
  SeverityCritical
} derive(Debug, Eq)

///|
pub(all) struct FieldRule {
  rule_id : String
  target_field : String
  severity : RuleSeverity
  rule_description : String
  enabled : Bool
} derive(Debug, Eq)

///|
pub fn FieldRule::new(
  rule_id : String,
  target_field : String,
  severity? : RuleSeverity = SeverityError,
  rule_description? : String = "",
  enabled? : Bool = true,
) -> FieldRule {
  { rule_id, target_field, severity, rule_description, enabled }
}

///|
pub(all) struct ContractPolicy {
  policy_id : String
  name : String
  rules : Array[FieldRule]
  allow_unknown_fields : Bool
  strict_null_check : Bool
} derive(Debug, Eq)

///|
pub fn ContractPolicy::default() -> ContractPolicy {
  {
    policy_id: "default_policy",
    name: "Standard Data Governance Policy",
    rules: [],
    allow_unknown_fields: false,
    strict_null_check: true,
  }
}
