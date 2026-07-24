///|
test "diff: breaking rules classification" {
  let t_int = @types.DataType::Primitive(@types.PrimitiveKind::PInt)
  let t_str = @types.DataType::Primitive(@types.PrimitiveKind::PString)
  let v = classify_breaking_change("age", t_int, t_str)
  assert_true(v is Some(_))
  assert_eq(v.unwrap().rule_code, "BRK-001")

  let violations = check_enum_shrinking("status", ["ACTIVE", "INACTIVE"], [
    "ACTIVE",
  ])
  assert_eq(violations.length(), 1)
  assert_eq(violations[0].rule_code, "BRK-002")
}
