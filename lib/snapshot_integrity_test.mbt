///|
test "snapshot integrity validates metadata and subject identity" {
  let good = SchemaSnapshot::new(
    "orders",
    Schema::new("orders", "Orders", "1.0.0", "integrity-test", []),
    source="registry",
    created_at="2026-08-18T00:00:00Z",
  )
  let bad = SchemaSnapshot::new(
    "orders",
    Schema::new("payments", "Payments", "bad", "", []),
  )
  let report = validate_snapshot_integrity([good, bad])
  assert_false(report.is_healthy())
  assert_true(report.issues.length() >= 3)
  assert_true(report.to_markdown().contains("INVALID_VERSION"))
}
