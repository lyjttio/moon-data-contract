///|
test "contract_linter: field naming and doc checks" {
  let f1 = Field::new("UserName", DataType::Primitive(PrimitiveType::TString)) // Uppercase start, no doc
  let schema = Schema::new("linter_test", "Test", "1.0.0", "team", [f1])

  let issues = lint_contract_schema(schema)
  assert_eq(issues.length(), 2)
  assert_eq(issues[0].rule_id, "LINT-001")
  assert_eq(issues[1].rule_id, "LINT-002")
}
