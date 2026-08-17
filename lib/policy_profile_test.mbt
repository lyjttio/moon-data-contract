///|
test "policy profiles express deployment intent" {
  let production = policy_for_profile(Production)
  let development = policy_for_profile(Development)
  assert_eq(policy_profile_name(Production), "production")
  assert_eq(policy_profile_name(Development), "development")
  assert_true(production.max_risk_score < development.max_risk_score)
  assert_true(policy_validation_errors(production).length() == 0)
}

///|
test "policy builder rejects unusable risk limits" {
  let policy = GovernancePolicy::strict().with_max_risk_score(101)
  let errors = policy_validation_errors(policy)
  assert_true(errors.length() >= 1)
  assert_true(errors[0].contains("risk"))
}
