///|
test "validator: string to int coercion" {
  let v_str = FieldValue::VString("100")
  let coerced = coerce_value_to_type(
    v_str,
    DataType::Primitive(PrimitiveType::TInt),
  )
  assert_true(coerced is Some(_))
  assert_eq(coerced.unwrap(), FieldValue::VInt(100))

  let v_bool = FieldValue::VString("true")
  let coerced_bool = coerce_value_to_type(
    v_bool,
    DataType::Primitive(PrimitiveType::TBool),
  )
  assert_eq(coerced_bool.unwrap(), FieldValue::VBool(true))
}

///|
test "validator: validation options with coercion" {
  let f_age = Field::new("age", DataType::Primitive(PrimitiveType::TInt))
  let schema = Schema::new("user", "User", "1.0.0", "team", [f_age])

  let payload : Map[String, FieldValue] = { "age": VString("25") }
  let opts = ValidationOptions::{
    allow_extra_fields: false,
    enable_coercion: true,
    strict_enums: true,
  }

  let res = validate_payload_with_options(schema, payload, options=opts)
  assert_true(res.is_valid)
}
