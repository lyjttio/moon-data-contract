// MoonBit Data Contract & Schema Evolution Tool - Evolution Report Generator

pub fn EvolutionReport::to_markdown(self : EvolutionReport) -> String {
  let mut md = "# Schema Evolution Report: " + self.schema_id + "\n\n"
  md = md + "- **Base Version**: " + self.v1_version + "\n"
  md = md + "- **Target Version**: " + self.v2_version + "\n"
  md = md + "- **Compatibility Level**: " + self.level.to_string() + "\n"
  md = md + "- **Is Compatible**: " + (if self.is_compatible { "YES ✅" } else { "NO ❌" }) + "\n"
  md = md + "- **Breaking Changes**: " + self.breaking_count.to_string() + "\n"
  md = md + "- **Non-Breaking Changes**: " + self.non_breaking_count.to_string() + "\n\n"

  md = md + "## Change Details\n\n"
  md = md + "| Field | Impact | Change Type | Description |\n"
  md = md + "| :--- | :--- | :--- | :--- |\n"

  for i = 0; i < self.diffs.length(); i = i + 1 {
    let diff = self.diffs[i]
    let impact_str = match diff.impact {
      Breaking => "🚨 BREAKING"
      NonBreaking => "✨ NON_BREAKING"
    }
    md = md + "| `" + diff.field_name + "` | " + impact_str + " | " + diff.description + " |\n"
  }

  md
}

pub fn EvolutionReport::to_json_summary(self : EvolutionReport) -> String {
  let mut buf = "{\n"
  buf = buf + "  \"schema_id\": \"" + self.schema_id + "\",\n"
  buf = buf + "  \"v1\": \"" + self.v1_version + "\",\n"
  buf = buf + "  \"v2\": \"" + self.v2_version + "\",\n"
  buf = buf + "  \"level\": \"" + self.level.to_string() + "\",\n"
  buf = buf + "  \"is_compatible\": " + self.is_compatible.to_string() + ",\n"
  buf = buf + "  \"breaking_count\": " + self.breaking_count.to_string() + ",\n"
  buf = buf + "  \"non_breaking_count\": " + self.non_breaking_count.to_string() + "\n"
  buf = buf + "}"
  buf
}
