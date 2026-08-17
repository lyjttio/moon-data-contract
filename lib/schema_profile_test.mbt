///|
test "schema profile counts field shape and primitive distribution" {
  let nested = Field::new(
    "profile",
    DataType::StructDef([
      Field::new("active", DataType::Primitive(PrimitiveType::TBool)),
      Field::new(
        "age",
        DataType::Primitive(PrimitiveType::TInt),
        required=false,
      ),
      Field::new("label", DataType::Primitive(PrimitiveType::TString)),
    ]),
  )
  let schema = Schema::new("profile", "Profile", "1.0.0", "test", [
    Field::new("id", DataType::Primitive(PrimitiveType::TInt)),
    Field::new("ratio", DataType::Primitive(PrimitiveType::TDouble)),
    nested,
  ])
  let profile = profile_schema(schema)
  assert_eq(profile.total_fields, 6)
  assert_eq(profile.required_fields, 5)
  assert_eq(profile.optional_fields, 1)
  assert_eq(profile.bool_fields, 1)
  assert_eq(profile.int_fields, 2)
  assert_eq(profile.double_fields, 1)
  assert_eq(profile.string_fields, 1)
  assert_eq(profile.composite_fields, 1)
  assert_eq(profile.max_depth, 2)
  assert_eq(profile.primitive_fields(), 5)
  assert_eq(profile.complexity_score(), 11)
  assert_true(profile.to_json().contains("total_fields"))
}
