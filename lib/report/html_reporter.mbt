// MoonBit Data Contract - Standalone HTML Visual Evolution Report Exporter

///|
pub fn export_html_report(
  schema_id : String,
  v1_ver : String,
  v2_ver : String,
  level_name : String,
  is_compatible : Bool,
  breaking_count : Int,
  non_breaking_count : Int,
  details : Array[EvolutionDetail],
) -> String {
  let status_color = if is_compatible { "#10b981" } else { "#ef4444" }
  let status_badge = if is_compatible { "PASSED ✅" } else { "REJECTED ❌" }

  let mut html = "<!DOCTYPE html>\n<html lang=\"en\">\n<head>\n"
  html = html + "  <meta charset=\"UTF-8\">\n"
  html = html + "  <title>Schema Evolution Audit - " + schema_id + "</title>\n"
  html = html + "  <style>\n"
  html = html +
    "    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #0f172a; color: #f8fafc; margin: 0; padding: 32px; }\n"
  html = html +
    "    .card { background: #1e293b; border-radius: 12px; padding: 24px; margin-bottom: 24px; border: 1px solid #334155; }\n"
  html = html + "    h1 { font-size: 24px; margin-top: 0; color: #38bdf8; }\n"
  html = html +
    "    .badge { display: inline-block; padding: 6px 12px; border-radius: 20px; font-weight: bold; font-size: 14px; background: " +
    status_color +
    "; color: #fff; }\n"
  html = html +
    "    table { width: 100%; border-collapse: collapse; margin-top: 16px; }\n"
  html = html +
    "    th, td { text-align: left; padding: 12px; border-bottom: 1px solid #334155; }\n"
  html = html + "    th { background: #0f172a; color: #94a3b8; }\n"
  html = html + "    .breaking { color: #f87171; font-weight: bold; }\n"
  html = html + "    .non-breaking { color: #34d399; }\n"
  html = html + "  </style>\n</head>\n<body>\n"

  html = html + "  <div class=\"card\">\n"
  html = html + "    <h1>Schema Evolution Audit: " + schema_id + "</h1>\n"
  html = html +
    "    <p>Base Version: <strong>" +
    v1_ver +
    "</strong> &rarr; Target Version: <strong>" +
    v2_ver +
    "</strong></p>\n"
  html = html +
    "    <p>Compatibility Policy: <strong>" +
    level_name +
    "</strong></p>\n"
  html = html +
    "    <p>Status: <span class=\"badge\">" +
    status_badge +
    "</span></p>\n"
  html = html +
    "    <p>Breaking Changes: <strong>" +
    breaking_count.to_string() +
    "</strong> | Non-Breaking Changes: <strong>" +
    non_breaking_count.to_string() +
    "</strong></p>\n"
  html = html + "  </div>\n\n"

  html = html + "  <div class=\"card\">\n"
  html = html + "    <h2>Change Breakdown</h2>\n"
  html = html + "    <table>\n"
  html = html +
    "      <thead>\n        <tr><th>Field</th><th>Impact</th><th>Change Type</th><th>Description</th></tr>\n      </thead>\n"
  html = html + "      <tbody>\n"

  for i = 0; i < details.length(); i = i + 1 {
    let d = details[i]
    let impact_cls = if d.is_breaking { "breaking" } else { "non-breaking" }
    let impact_txt = if d.is_breaking { "BREAKING" } else { "NON_BREAKING" }
    html = html + "        <tr>\n"
    html = html + "          <td><code>" + d.field_name + "</code></td>\n"
    html = html +
      "          <td class=\"" +
      impact_cls +
      "\">" +
      impact_txt +
      "</td>\n"
    html = html + "          <td>" + d.change_type + "</td>\n"
    html = html + "          <td>" + d.description + "</td>\n"
    html = html + "        </tr>\n"
  }

  html = html + "      </tbody>\n    </table>\n  </div>\n"
  html = html + "</body>\n</html>\n"
  html
}
