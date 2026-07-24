///|
test "compat: backward compatibility pass and fail" {
  let f_id = Field::new("id", DataType::Primitive(PrimitiveType::TInt))
  let f_email = Field::new(
    "email",
    DataType::Primitive(PrimitiveType::TString),
    required=false,
  )

  let s1 = Schema::new("user", "User", "1.0.0", "team", [f_id])
  let s2_compatible = Schema::new("user", "User", "1.1.0", "team", [
    f_id, f_email,
  ])

  let report1 = check_compatibility(s1, s2_compatible, Backward)
  assert_true(report1.is_compatible)
  assert_eq(report1.breaking_count, 0)

  // s3 removes 'id' (breaking)
  let s3_breaking = Schema::new("user", "User", "2.0.0", "team", [f_email])
  let report2 = check_compatibility(s1, s3_breaking, Backward)
  assert_false(report2.is_compatible)
  assert_true(report2.breaking_count > 0)
}
