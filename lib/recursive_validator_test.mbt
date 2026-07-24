///|
test "recursive_validator: nested struct validation" {
  let f1 = Field::new(
    "zip",
    DataType::Primitive(PrimitiveType::TString),
    required=true,
  )
  let payload : Map[String, FieldValue] = Map([])

  let errs = validate_nested_struct("user.address", [f1], payload)
  assert_eq(errs.length(), 1)
  assert_eq(errs[0].field, "user.address.zip")
  assert_eq(errs[0].code, "NESTED_REQUIRED_MISSING")
}
