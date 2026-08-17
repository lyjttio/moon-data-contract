///|
test "report format routing keeps output contracts stable" {
  let result = govern_subject(
    benchmark_governance_store(),
    "orders",
    GovernancePolicy::strict(),
    CompatibilityLevel::Backward,
  )
  assert_true(
    render_governance_result(result, Markdown).contains("Governance Report"),
  )
  assert_true(render_governance_result(result, Json).contains("\"subject\""))
  assert_true(render_governance_result(result, Junit).contains("testsuite"))
}
