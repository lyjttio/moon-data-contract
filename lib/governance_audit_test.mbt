///|
test "governance audit summary exposes release evidence" {
  let result = govern_subject(
    benchmark_governance_store(),
    "orders",
    GovernancePolicy::strict(),
    CompatibilityLevel::Backward,
  )
  let audit = governance_audit_summary(result)
  assert_eq(audit.subject, "orders")
  assert_true(audit.lines.length() >= 4)
  assert_true(audit.lines[0].contains("orders"))
}
