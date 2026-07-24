// MoonBit Data Contract - Automated Contract Linter & Style Checker

///|
pub(all) enum LintSeverity {
  LintWarning
  LintError
} derive(Debug, Eq)

///|
pub(all) struct LintIssue {
  field_name : String
  rule_id : String
  severity : LintSeverity
  message : String
} derive(Debug, Eq)

///|
pub fn lint_contract_schema(schema : Schema) -> Array[LintIssue] {
  let issues : Array[LintIssue] = []

  // Rule 1: Check camelCase or snake_case field naming
  for i = 0; i < schema.fields.length(); i = i + 1 {
    let f = schema.fields[i]
    if f.name.length() > 0 {
      let first_ch = f.name[0]
      if first_ch >= 'A' && first_ch <= 'Z' {
        issues.push({
          field_name: f.name,
          rule_id: "LINT-001",
          severity: LintWarning,
          message: "Field name '" +
          f.name +
          "' starts with uppercase. Recommended: snake_case or camelCase",
        })
      }
    }

    // Rule 2: Check missing description
    if f.description.length() == 0 {
      issues.push({
        field_name: f.name,
        rule_id: "LINT-002",
        severity: LintWarning,
        message: "Field '" + f.name + "' is missing documentation description",
      })
    }
  }

  issues
}
