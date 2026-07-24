///|
test "report: html and junit xml export" {
  let detail1 = EvolutionDetail::{
    field_name: "email",
    change_type: "FIELD_REMOVED",
    is_breaking: true,
    description: "Field email removed",
  }

  let html = export_html_report(
    "user_audit",
    "1.0.0",
    "2.0.0",
    "BACKWARD",
    false,
    1,
    0,
    [detail1],
  )
  assert_true(html.contains("<!DOCTYPE html>"))
  assert_true(html.contains("REJECTED ❌"))

  let junit = export_junit_xml("user_audit", false, 1, [detail1])
  assert_true(junit.contains("<?xml version=\"1.0\""))
  assert_true(junit.contains("<failure message=\"Breaking Change Violation\">"))
}
