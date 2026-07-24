///|
test "report: markdown and json generation" {
  let f1 = Field::new("id", DataType::Primitive(PrimitiveType::TInt))
  let f2 = Field::new("name", DataType::Primitive(PrimitiveType::TString))
  let s1 = Schema::new("order", "Order", "1.0.0", "team", [f1])
  let s2 = Schema::new("order", "Order", "2.0.0", "team", [f1, f2])

  let report = check_compatibility(s1, s2, Backward)
  let md = report.to_markdown()
  let json_summary = report.to_json_summary()

  assert_true(md.contains("# Schema Evolution Report: order"))
  assert_true(md.contains("Base Version**: 1.0.0"))
  assert_true(json_summary.contains("\"schema_id\": \"order\""))
}
