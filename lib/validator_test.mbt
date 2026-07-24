///|
test "validator: valid payload passes" {
  let f_id = Field::new(
    "id",
    DataType::Primitive(PrimitiveType::TInt),
    primary_key=true,
  )
  let f_age = Field::new("age", DataType::Primitive(PrimitiveType::TInt), constraint={
    min_value: Some(18.0),
    max_value: Some(100.0),
    pattern: None,
    allowed_values: None,
  })
  let schema = Schema::new("user_schema", "User", "1.0.0", "team", [f_id, f_age])

  let payload : Map[String, FieldValue] = { "id": VInt(1001), "age": VInt(25) }

  let res = validate_schema_payload(schema, payload)
  assert_true(res.is_valid)
  assert_eq(res.errors.length(), 0)
}

///|
test "validator: missing required field and range error" {
  let f_id = Field::new(
    "id",
    DataType::Primitive(PrimitiveType::TInt),
    primary_key=true,
  )
  let f_age = Field::new("age", DataType::Primitive(PrimitiveType::TInt), constraint={
    min_value: Some(18.0),
    max_value: Some(100.0),
    pattern: None,
    allowed_values: None,
  })
  let schema = Schema::new("user_schema", "User", "1.0.0", "team", [f_id, f_age])

  let payload : Map[String, FieldValue] = {
    "age": VInt(15), // Below min age 18, and id is missing
  }

  let res = validate_schema_payload(schema, payload)
  assert_false(res.is_valid)
  assert_true(res.errors.length() >= 2)
}
