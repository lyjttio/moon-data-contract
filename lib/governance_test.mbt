///|
fn governance_store(target : Schema) -> SnapshotStore {
  let store = SnapshotStore::new()
  let base = SchemaSnapshot::new(
    "orders",
    snapshot_fixture("1.0.0"),
    source="fixture",
  )
  let next = SchemaSnapshot::new("orders", target, source="fixture")
  ignore(store.insert(base))
  ignore(store.insert(next))
  store
}

///|
test "governance blocks an empty subject" {
  let result = govern_subject(
    SnapshotStore::new(),
    "orders",
    GovernancePolicy::strict(),
    CompatibilityLevel::Backward,
  )
  assert_eq(result.status, GovernanceStatus::Blocked)
  assert_false(result.is_release_allowed())
  assert_true(result.chain_report.issues.length() >= 1)
}

///|
test "governance allows a compatible optional-field chain" {
  let base = snapshot_fixture("1.0.0")
  let target = Schema::new("orders", "Orders", "1.1.0", "fixture", [
    base.fields[0],
    Field::new("email", Primitive(TString), required=false),
  ])
  let result = govern_subject(
    governance_store(target),
    "orders",
    GovernancePolicy::strict(),
    CompatibilityLevel::Backward,
  )
  assert_eq(result.status, GovernanceStatus::Ready)
  assert_true(result.is_release_allowed())
  assert_eq(result.metrics.transition_count, 1)
  assert_eq(result.metrics.blocking_count, 0)
}

///|
test "governance blocks a required-field transition and exposes findings" {
  let base = snapshot_fixture("1.0.0")
  let target = Schema::new("orders", "Orders", "1.1.0", "fixture", [
    base.fields[0],
    Field::new("account_id", Primitive(TString)),
  ])
  let result = govern_subject(
    governance_store(target),
    "orders",
    GovernancePolicy::strict(),
    CompatibilityLevel::Backward,
  )
  assert_eq(result.status, GovernanceStatus::Blocked)
  assert_false(result.is_release_allowed())
  assert_true(result.blocking_findings().length() >= 1)
  assert_true(result.risk_score() >= 10)
}

///|
test "governance result is deterministic for repeated evaluation" {
  let base = snapshot_fixture("1.0.0")
  let target = Schema::new("orders", "Orders", "1.1.0", "fixture", [
    base.fields[0],
    Field::new("email", Primitive(TString), required=false),
  ])
  let first = govern_subject(
    governance_store(target),
    "orders",
    GovernancePolicy::strict(),
    CompatibilityLevel::Backward,
  )
  let second = govern_subject(
    governance_store(target),
    "orders",
    GovernancePolicy::strict(),
    CompatibilityLevel::Backward,
  )
  assert_eq(first, second)
}
