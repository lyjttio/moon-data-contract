///|
fn approval_result_fixture() -> GovernanceResult {
  govern_subject(
    benchmark_governance_store(),
    "orders",
    GovernancePolicy::strict(),
    CompatibilityLevel::Backward,
  )
}

///|
test "approval ledger records and resolves a reviewer decision" {
  let ledger = ApprovalLedger::new()
  let result = ledger.submit(
    ApprovalRecord::new(
      "orders",
      "2.0.0",
      "lyjttio",
      Approved,
      "migration reviewed",
    ),
  )
  assert_true(result is Ok(_))
  assert_true(ledger.has_approval("orders", "2.0.0"))
  assert_eq(ledger.reviewer_count("orders", "2.0.0"), 1)
}

///|
test "blocked governance cannot be released by an approval" {
  let result = approval_result_fixture()
  let ledger = ApprovalLedger::new()
  ignore(
    ledger.submit(
      ApprovalRecord::new("orders", "2.0.0", "lyjttio", Approved, "reviewed"),
    ),
  )
  let gate = evaluate_release_gate(result, ledger)
  assert_false(gate.allowed)
  assert_true(gate.reason.contains("blocked"))
}
