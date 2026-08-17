///|
test "governance reports render stable markdown JSON and JUnit" {
  let base = snapshot_fixture("1.0.0")
  let target = Schema::new("orders", "Orders", "1.1.0", "fixture", [
    base.fields[0],
    Field::new("email", Primitive(TString), required=false),
  ])
  let result = govern_subject(
    governance_store(target),
    "orders",
    GovernancePolicy::strict(),
    CompatibilityLevel::Backward,
  )
  let markdown = result.to_markdown()
  let json = result.to_json()
  let junit = result.to_junit()
  assert_true(markdown.contains("# Contract Governance Report"))
  assert_true(markdown.contains("READY"))
  assert_true(json.contains("\"subject\": \"orders\""))
  assert_true(json.contains("\"transition_count\": 1"))
  assert_true(junit.contains("testsuite"))
  assert_true(junit.contains("tests=\"0\""))
  assert_eq(markdown, result.to_markdown())
  assert_eq(json, result.to_json())
}

///|
test "blocked governance report contains JUnit failure" {
  let base = snapshot_fixture("1.0.0")
  let target = Schema::new("orders", "Orders", "1.1.0", "fixture", [
    base.fields[0],
    Field::new("account_id", Primitive(TString)),
  ])
  let result = govern_subject(
    governance_store(target),
    "orders",
    GovernancePolicy::strict(),
    CompatibilityLevel::Backward,
  )
  assert_true(result.to_markdown().contains("BLOCKED"))
  assert_true(result.to_junit().contains("failure"))
}

///|
test "JSON escaping protects quotes backslashes and newlines" {
  assert_eq(
    json_escape("quote\" slash\\ line\nnext\rtab\t"),
    "quote\\\" slash\\\\ line\\nnext\\rtab\\t",
  )
}
