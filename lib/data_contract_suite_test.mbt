///|
test "data_contract_suite: full end-to-end multi-version lifecycle" {
  let f_id = Field::new(
    "id",
    DataType::Primitive(PrimitiveType::TInt),
    primary_key=true,
  )
  let f_name = Field::new("name", DataType::Primitive(PrimitiveType::TString))
  let f_email = Field::new(
    "email",
    DataType::Primitive(PrimitiveType::TString),
    required=false,
  )

  let s1 = Schema::new("contract_app", "AppEvent", "1.0.0", "team", [
    f_id, f_name,
  ])
  let s2 = Schema::new("contract_app", "AppEvent", "1.1.0", "team", [
    f_id, f_name, f_email,
  ])

  let diffs = diff_schemas(s1, s2)
  let report = check_compatibility(s1, s2, Backward)

  assert_true(report.is_compatible)
  assert_eq(diffs.length(), 1)

  let payload = generate_sample_payload(s2, 101)
  let val_res = validate_schema_payload(s2, payload)
  assert_true(val_res.is_valid)
}
