///|
test "governance trace records every deterministic pipeline stage" {
  let traced = trace_governance(
    benchmark_governance_store(),
    "orders",
    GovernancePolicy::strict(),
    CompatibilityLevel::Backward,
  )
  assert_true(traced.trace.events.length() >= 6)
  assert_eq(traced.result.subject, "orders")
  assert_true(traced.trace.to_markdown().contains("Policy evaluated"))
  assert_true(traced.trace.to_json().contains("SNAPSHOT_LOADED"))
  assert_true(traced.trace.stage_count("migration") >= 1)
}
