///|
test "types: field and schema construction" {
  let f1 = Field::new(
    "id",
    DataType::Primitive(PrimitiveType::TInt),
    primary_key=true,
    description="User ID",
  )
  let f2 = Field::new(
    "name",
    DataType::Primitive(PrimitiveType::TString),
    required=true,
  )
  let schema = Schema::new("user_schema", "User", "1.0.0", "data_team", [f1, f2])
  assert_eq(schema.id, "user_schema")
  assert_eq(schema.version, "1.0.0")
  assert_eq(schema.fields.length(), 2)
  assert_eq(schema.fields[0].primary_key, true)
}

///|
test "types: compatibility level conversion" {
  assert_eq(
    CompatibilityLevel::from_string("BACKWARD"),
    CompatibilityLevel::Backward,
  )
  assert_eq(
    CompatibilityLevel::from_string("FORWARD"),
    CompatibilityLevel::Forward,
  )
  assert_eq(CompatibilityLevel::from_string("FULL"), CompatibilityLevel::Full)
  assert_eq(
    CompatibilityLevel::from_string("NONE"),
    CompatibilityLevel::NoneLevel,
  )

  assert_eq(CompatibilityLevel::Backward.to_string(), "BACKWARD")
  assert_eq(CompatibilityLevel::Forward.to_string(), "FORWARD")
}
