///|
test "governance recommendations prioritize actionable release work" {
  let result = govern_subject(
    benchmark_governance_store(),
    "orders",
    GovernancePolicy::strict(),
    CompatibilityLevel::Backward,
  )
  let checklist = build_release_checklist(result, ApprovalLedger::new())
  let recommendations = recommend_governance_actions(result, checklist)
  assert_true(recommendations.length() >= 2)
  assert_eq(recommendations[0].priority, Critical)
  assert_true(
    recommendation_summary("orders", recommendations).contains("orders"),
  )
  assert_true(
    recommendations_to_markdown("orders", recommendations).contains(
      "Recommendations",
    ),
  )
  assert_true(recommendation_count(recommendations, Critical) >= 1)
  assert_true(
    recommendation_codes(recommendations).contains("RESOLVE_BLOCKING_FINDINGS"),
  )
  assert_true(
    recommendations_to_text("orders", recommendations).contains("CRITICAL"),
  )
  assert_true(
    recommendation_has_code(recommendations, "RESOLVE_BLOCKING_FINDINGS"),
  )
  assert_eq(recommendation_priority_rank(recommendations[0].priority), 3)
  assert_eq(recommendation_highest_priority(recommendations), Critical)
  assert_true(recommendation_action_plan(recommendations).contains("1."))
  assert_true(recommendation_has_priority(recommendations, Critical))
  assert_eq(recommendation_priority_label(Critical), "critical release blocker")
  assert_true(recommendation_priority_is_blocking(Critical))
}
