///|
fn policy_base_schema() -> Schema {
  Schema::new("orders", "Orders", "1.0.0", "fixture", [
    Field::new("id", DataType::Primitive(PrimitiveType::TInt), primary_key=true),
  ])
}

///|
fn policy_required_target() -> Schema {
  let base = policy_base_schema()
  Schema::new(base.id, base.name, "1.1.0", base.owner, [
    base.fields[0],
    Field::new("account_id", DataType::Primitive(PrimitiveType::TString)),
  ])
}

///|
test "strict policy blocks a required field addition" {
  let findings = evaluate_policy(
    GovernancePolicy::strict(),
    policy_base_schema(),
    policy_required_target(),
    CompatibilityLevel::Backward,
  )
  assert_true(findings.length() >= 1)
  assert_eq(findings[0].rule_id, "required-field-added")
  assert_true(findings[0].blocking)
  assert_eq(policy_decision(findings), PolicyDecision::Blocked)
}

///|
test "policy exception preserves evidence and allows the exception" {
  let policy = GovernancePolicy::strict().with_exception(
    PolicyException::new(
      "orders", "account_id", "required-field-added", "backfill runs before publication",
    ),
  )
  let findings = evaluate_policy(
    policy,
    policy_base_schema(),
    policy_required_target(),
    CompatibilityLevel::Backward,
  )
  assert_eq(findings.length(), 1)
  assert_true(findings[0].exception_applied)
  assert_true(!findings[0].blocking)
  assert_eq(policy_decision(findings), PolicyDecision::Allow)
}

///|
test "policy findings are deterministically ordered" {
  let target = Schema::new("orders", "Orders", "1.1.0", "fixture", [
    Field::new("id", Primitive(TInt), primary_key=true),
    Field::new("z_field", Primitive(TString)),
    Field::new("a_field", Primitive(TString)),
  ])
  let first = evaluate_policy(
    GovernancePolicy::strict(),
    policy_base_schema(),
    target,
    CompatibilityLevel::Backward,
  )
  let second = evaluate_policy(
    GovernancePolicy::strict(),
    policy_base_schema(),
    target,
    CompatibilityLevel::Backward,
  )
  assert_eq(first, second)
  assert_true(first.length() >= 2)
  assert_eq(first[0].field_name, "a_field")
}

///|
test "policy risk budget creates a blocking finding" {
  let policy = GovernancePolicy::strict().with_max_risk_score(0)
  let findings = evaluate_policy(
    policy,
    policy_base_schema(),
    policy_required_target(),
    CompatibilityLevel::Backward,
  )
  assert_true(findings.length() >= 2)
  let mut has_budget_finding = false
  for finding in findings {
    if finding.rule_id == "risk-budget-exceeded" {
      has_budget_finding = true
    }
  }
  assert_true(has_budget_finding)
  assert_eq(policy_decision(findings), PolicyDecision::Blocked)
}

///|
test "permissive policy allows type and constraint changes" {
  let base = Schema::new("orders", "Orders", "1.0.0", "fixture", [
    Field::new("amount", Primitive(TInt), constraint={
      min_value: Some(0.0),
      max_value: None,
      pattern: None,
      allowed_values: None,
    }),
  ])
  let target = Schema::new("orders", "Orders", "1.1.0", "fixture", [
    Field::new("amount", Primitive(TDouble), constraint={
      min_value: Some(-1.0),
      max_value: None,
      pattern: None,
      allowed_values: None,
    }),
  ])
  let findings = evaluate_policy(
    GovernancePolicy::permissive(),
    base,
    target,
    CompatibilityLevel::Backward,
  )
  assert_eq(policy_decision(findings), PolicyDecision::Allow)
}
