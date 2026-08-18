///|
test "risk bands and metric summaries are bounded" {
  let result = govern_subject(
    benchmark_governance_store(),
    "orders",
    GovernancePolicy::strict(),
    CompatibilityLevel::Backward,
  )
  let band = risk_band(result.risk_score())
  assert_eq(band, Medium)
  assert_true(result.metrics.summary().contains("transitions"))
}
