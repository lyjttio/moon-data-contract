///|
test "governance delta identifies risk and finding changes" {
  let base = Schema::new("orders", "Orders", "1.0.0", "delta-test", [])
  let optional = Schema::new("orders", "Orders", "1.1.0", "delta-test", [
    Field::new("id", Primitive(TInt), required=false),
  ])
  let first_store = SnapshotStore::new()
  ignore(
    first_store.insert(
      SchemaSnapshot::new(
        "orders",
        base,
        source="delta",
        created_at="2026-08-18T00:00:00Z",
      ),
    ),
  )
  let first = govern_subject(
    first_store,
    "orders",
    GovernancePolicy::strict(),
    CompatibilityLevel::Backward,
  )
  let second_store = SnapshotStore::new()
  ignore(
    second_store.insert(
      SchemaSnapshot::new(
        "orders",
        base,
        source="delta",
        created_at="2026-08-18T00:00:00Z",
      ),
    ),
  )
  ignore(
    second_store.insert(
      SchemaSnapshot::new(
        "orders",
        optional,
        source="delta",
        created_at="2026-08-18T00:01:00Z",
      ),
    ),
  )
  let second = govern_subject(
    second_store,
    "orders",
    GovernancePolicy::strict(),
    CompatibilityLevel::Backward,
  )
  let delta = compare_governance_results(first, second)
  assert_eq(delta.current_transition_count, 1)
  assert_true(delta.risk_delta >= 0)
}
