///|
test "schema_comparator: batch schema comparison" {
  let f1 = Field::new("id", DataType::Primitive(PrimitiveType::TInt))
  let s1 = Schema::new("user_a", "UserA", "1.0.0", "team", [f1])
  let s2 = Schema::new("user_b", "UserB", "1.0.0", "team", [f1])

  let res = batch_compare_schemas([s1], [s2])
  assert_eq(res.length(), 1)
  assert_true(res[0].is_identical)
}
