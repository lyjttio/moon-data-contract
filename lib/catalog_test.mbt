///|
test "contract catalog indexes subjects and governs all releases" {
  let catalog = ContractCatalog::new()
  for snapshot in benchmark_governance_snapshots() {
    assert_true(catalog.register(snapshot) is Ok(_))
  }
  assert_eq(catalog.subject_count(), 1)
  assert_eq(catalog.subjects(), ["orders"])
  let results = catalog.govern_all(
    GovernancePolicy::strict(),
    CompatibilityLevel::Backward,
  )
  assert_eq(results.length(), 1)
  assert_eq(results[0].subject, "orders")
}

///|
test "catalog rejects duplicate versions without losing the index" {
  let catalog = ContractCatalog::new()
  let snapshot = SchemaSnapshot::new(
    "orders",
    Schema::new("orders", "Orders", "1.0.0", "catalog-test", []),
  )
  assert_true(catalog.register(snapshot) is Ok(_))
  assert_true(catalog.register(snapshot) is Err(_))
  assert_eq(catalog.subject_count(), 1)
}
