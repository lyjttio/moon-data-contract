test "report: markdown report formatting" {
  let detail1 = EvolutionDetail::{
    field_name: "email",
    change_type: "FIELD_ADDED",
    is_breaking: false,
    description: "Added optional field email",
  }
  let report = ContractReport::{
    schema_id: "user_account",
    base_version: "1.0.0",
    target_version: "1.1.0",
    level_name: "BACKWARD",
    is_compatible: true,
    details: [detail1],
  }

  let md = report.to_markdown()
  assert_true(md.contains("Schema Evolution Audit Report"))
  assert_true(md.contains("user_account"))
  assert_true(md.contains("PASSED ✅"))
}
