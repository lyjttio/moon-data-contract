///|
test "governance replay produces an auditable CI execution record" {
  let request = GovernanceReplayRequest::new(
    "orders",
    benchmark_governance_policy(),
    CompatibilityLevel::Backward,
    DryRun,
  )
  let snapshots = benchmark_governance_snapshots()
  let policy_findings = evaluate_policy(
    benchmark_governance_policy(),
    snapshots[1].schema,
    snapshots[2].schema,
    CompatibilityLevel::Backward,
  )
  let mut has_exception = false
  for finding in policy_findings {
    if finding.exception_applied {
      has_exception = true
    }
  }
  assert_true(has_exception)
  let release_findings = evaluate_policy(
    benchmark_governance_policy(),
    snapshots[2].schema,
    snapshots[3].schema,
    CompatibilityLevel::Backward,
  )
  let mut has_region_exception = false
  for finding in release_findings {
    if finding.exception_applied {
      has_region_exception = true
    }
  }
  assert_true(has_region_exception)
  let replay = replay_governance(benchmark_governance_store(), request)
  assert_eq(replay.result.subject, "orders")
  assert_eq(replay.result.status, Ready)
  assert_true(replay.steps.length() >= 6)
  assert_true(replay.to_markdown().contains("Governance Replay"))
  assert_true(replay.to_json().contains("publishable"))
  assert_true(replay.failed_step_count() == 0)
  assert_true(replay.has_stage("policy"))
  assert_eq(replay.mode_label(), "DRY_RUN")
  assert_true(replay.recommendation_count() >= 1)
}
