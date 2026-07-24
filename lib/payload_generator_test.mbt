///|
test "payload_generator: generate sample test payload" {
  let f1 = Field::new("id", DataType::Primitive(PrimitiveType::TInt))
  let f2 = Field::new("name", DataType::Primitive(PrimitiveType::TString))
  let schema = Schema::new("sample", "Sample", "1.0.0", "team", [f1, f2])

  let payload = generate_sample_payload(schema, 42)
  let val_res = validate_schema_payload(schema, payload)
  assert_true(val_res.is_valid)
}
