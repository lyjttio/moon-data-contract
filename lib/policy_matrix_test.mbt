///|
test "policy matrix evaluates every policy and compatibility level" {
  let base = Schema::new("orders", "Orders", "1.0.0", "matrix-test", [])
  let target = Schema::new("orders", "Orders", "1.1.0", "matrix-test", [
    Field::new("id", Primitive(TInt), required=false),
  ])
  let report = evaluate_policy_matrix(base, target, [Production, Development], [
    Backward,
    Full,
  ])
  assert_eq(report.cells.length(), 4)
  assert_eq(report.allowed_count, 4)
  assert_true(report.to_markdown().contains("Production"))
  assert_true(report.to_json().contains("allowed_count"))
}
