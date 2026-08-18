///|
fn governance_store(target : Schema) -> SnapshotStore {
  let store = SnapshotStore::new()
  let base = SchemaSnapshot::new(
    "orders",
    snapshot_fixture("1.0.0"),
    source="fixture",
    created_at="2026-08-18T00:00:00Z",
  )
  let next = SchemaSnapshot::new(
    "orders",
    target,
    source="fixture",
    created_at="2026-08-18T00:01:00Z",
  )
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

///|
test "governance blocks metadata integrity failures and reports their count" {
  let store = SnapshotStore::new()
  ignore(
    store.insert(
      SchemaSnapshot::new(
        "orders",
        Schema::new("payments", "Payments", "1.0.0", "", []),
        source="fixture",
        created_at="2026-08-18T00:00:00Z",
      ),
    ),
  )
  let result = govern_subject(
    store,
    "orders",
    GovernancePolicy::strict(),
    CompatibilityLevel::Backward,
  )
  assert_eq(result.status, GovernanceStatus::Blocked)
  assert_true(result.metrics.integrity_issue_count >= 2)
}

///|
test "governance applies the risk budget across the complete snapshot chain" {
  let store = SnapshotStore::new()
  let base = Schema::new("orders", "Orders", "1.0.0", "fixture", [
    Field::new("id", Primitive(TInt), primary_key=true),
  ])
  let first = Schema::new("orders", "Orders", "1.1.0", "fixture", [
    base.fields[0],
    Field::new("account", Primitive(TString)),
  ])
  let second = Schema::new("orders", "Orders", "1.2.0", "fixture", [
    first.fields[0],
    first.fields[1],
    Field::new("region", Primitive(TString)),
  ])
  ignore(
    store.insert(
      SchemaSnapshot::new(
        "orders",
        base,
        source="fixture",
        created_at="2026-08-18T00:00:00Z",
      ),
    ),
  )
  ignore(
    store.insert(
      SchemaSnapshot::new(
        "orders",
        first,
        source="fixture",
        created_at="2026-08-18T00:01:00Z",
      ),
    ),
  )
  ignore(
    store.insert(
      SchemaSnapshot::new(
        "orders",
        second,
        source="fixture",
        created_at="2026-08-18T00:02:00Z",
      ),
    ),
  )
  let result = govern_subject(
    store,
    "orders",
    GovernancePolicy::strict().with_max_risk_score(10),
    CompatibilityLevel::Backward,
  )
  assert_eq(result.status, GovernanceStatus::Blocked)
  let mut has_chain_budget = false
  for finding in result.findings {
    if finding.rule_id == "chain-risk-budget-exceeded" {
      has_chain_budget = true
    }
  }
  assert_true(has_chain_budget)
}
