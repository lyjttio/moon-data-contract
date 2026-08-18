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
test "JUnit report escapes XML field names and preserves Unicode" {
  let base = snapshot_fixture("1.0.0")
  let target = Schema::new("orders", "Orders", "1.1.0", "fixture", [
    base.fields[0],
    Field::new("a<&🤣", Primitive(TString)),
  ])
  let junit = govern_subject(
    governance_store(target),
    "orders",
    GovernancePolicy::strict(),
    CompatibilityLevel::Backward,
  ).to_junit()
  assert_true(junit.contains("a&lt;&amp;🤣"))
}

///|
test "JSON escaping protects quotes backslashes and newlines" {
  assert_eq(
    json_escape("quote\" slash\\ line\nnext\rtab\t"),
    "quote\\\" slash\\\\ line\\nnext\\rtab\\t",
  )
  assert_eq(json_escape("unicode 🤣"), "unicode 🤣")
  assert_eq(
    json_escape("control\b\u{0B}\u{0C}\u{00}"),
    "control\\b\\u000b\\f\\u0000",
  )
}

///|
test "governance JSON preserves finding evidence and migration actions" {
  let result = govern_subject(
    benchmark_governance_store(),
    "orders",
    GovernancePolicy::strict(),
    CompatibilityLevel::Backward,
  )
  let json = result.to_json()
  assert_true(json.contains("Field 'region'"))
  assert_true(json.contains("risk_score"))
  assert_true(json.contains("exception_applied"))
  assert_true(json.contains("migration_plans"))
  assert_true(json.contains("add_required_field"))
}
