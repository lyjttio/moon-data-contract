///|
test "constraints: array min/max and unique rules" {
  let rule = ArrayRule::{
    min_items: Some(2),
    max_items: Some(4),
    unique_items: true,
  }

  let v1 = check_array_rule("tags", ["a"], rule)
  assert_true(v1.length() > 0) // Min items violation

  let v2 = check_array_rule("tags", ["a", "b", "a"], rule)
  assert_true(v2.length() > 0) // Unique items violation

  let v3 = check_array_rule("tags", ["a", "b", "c"], rule)
  assert_eq(v3.length(), 0)
}
