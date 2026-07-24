test "ast_diff: enum variants addition and removal" {
  let e1 = DataType::EnumDef(["ACTIVE", "INACTIVE"])
  let e2 = DataType::EnumDef(["ACTIVE", "ARCHIVED"])

  let nodes = diff_data_types("field_status", e1, e2)
  assert_eq(nodes.length(), 2)

  let bump = calculate_version_bump(nodes)
  assert_eq(bump, RecommendedBump::BumpMajor)

  let risk = calculate_total_risk_score(nodes)
  assert_true(risk >= 80)
}
