///|
test "release checklist explains every governance gate" {
  let result = govern_subject(
    benchmark_governance_store(),
    "orders",
    GovernancePolicy::strict(),
    CompatibilityLevel::Backward,
  )
  let checklist = build_release_checklist(result, ApprovalLedger::new())
  assert_true(checklist.items.length() >= 5)
  assert_false(checklist.is_ready())
  assert_true(checklist.to_markdown().contains("Release Checklist"))
}
