// Format routing keeps CI integrations independent from renderer details.

///|
pub(all) enum GovernanceReportFormat {
  Markdown
  Json
  Junit
} derive(Debug, Eq)

///|
pub fn GovernanceReportFormat::extension(
  self : GovernanceReportFormat,
) -> String {
  match self {
    Markdown => "md"
    Json => "json"
    Junit => "xml"
  }
}

///|
pub fn render_governance_result(
  result : GovernanceResult,
  format : GovernanceReportFormat,
) -> String {
  match format {
    Markdown => result.to_markdown()
    Json => result.to_json()
    Junit => result.to_junit()
  }
}

///|
pub fn governance_report_formats() -> Array[GovernanceReportFormat] {
  [Markdown, Json, Junit]
}

///|
pub fn governance_report_bundle(result : GovernanceResult) -> Array[String] {
  let outputs : Array[String] = []
  for format in governance_report_formats() {
    outputs.push(render_governance_result(result, format))
  }
  outputs
}

///|
pub fn governance_report_filename(
  subject : String,
  format : GovernanceReportFormat,
) -> String {
  "governance-" + subject + "." + format.extension()
}

///|
pub fn governance_report_bundle_summary(result : GovernanceResult) -> String {
  let outputs = governance_report_bundle(result)
  "subject=" +
  result.subject +
  ", formats=" +
  outputs.length().to_string() +
  ", markdown_bytes=" +
  outputs[0].length().to_string() +
  ", json_bytes=" +
  outputs[1].length().to_string() +
  ", junit_bytes=" +
  outputs[2].length().to_string()
}
