test "constraints: numeric range checks" {
  let rule = @types.NumericRange::{
    min_value: Some(10.0),
    max_value: Some(100.0),
    exclusive_min: true,
    exclusive_max: false,
    multiple_of: Some(5.0),
  }

  let v1 = check_numeric_range("age", 10.0, rule)
  assert_true(v1.length() > 0) // Strictly greater than 10

  let v2 = check_numeric_range("age", 25.0, rule)
  assert_eq(v2.length(), 0)

  let v3 = check_numeric_range("age", 27.0, rule)
  assert_true(v3.length() > 0) // Not multiple of 5
}

test "constraints: string format checks (email, uuid, ipv4)" {
  assert_true(is_valid_email("alice@example.com"))
  assert_false(is_valid_email("invalid_email_str"))

  assert_true(is_valid_uuid("550e8400-e29b-41d4-a716-446655440000"))
  assert_false(is_valid_uuid("550e8400-e29b-not-uuid"))

  assert_true(is_valid_ipv4("192.168.1.1"))
  assert_false(is_valid_ipv4("256.300.1"))
}
