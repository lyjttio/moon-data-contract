// MoonBit Data Contract - Automatic Migration & Release Changelog Generator

///|
pub(all) struct MigrationChangelog {
  schema_id : String
  from_version : String
  to_version : String
  breaking_notes : Array[String]
  non_breaking_notes : Array[String]
} derive(Debug, Eq)

///|
pub fn build_changelog(
  schema_id : String,
  v1_ver : String,
  v2_ver : String,
  diffs : Array[DiffEntry],
) -> MigrationChangelog {
  let breaking : Array[String] = []
  let non_breaking : Array[String] = []

  for i = 0; i < diffs.length(); i = i + 1 {
    let d = diffs[i]
    if d.impact == Breaking {
      breaking.push("Field '" + d.field_name + "': " + d.description)
    } else {
      non_breaking.push("Field '" + d.field_name + "': " + d.description)
    }
  }

  {
    schema_id,
    from_version: v1_ver,
    to_version: v2_ver,
    breaking_notes: breaking,
    non_breaking_notes: non_breaking,
  }
}

///|
pub fn MigrationChangelog::to_markdown(self : MigrationChangelog) -> String {
  let mut md = "## Release Migration Notes: " +
    self.schema_id +
    " (" +
    self.from_version +
    " -> " +
    self.to_version +
    ")\n\n"
  if self.breaking_notes.length() > 0 {
    md = md + "### ⚠️ Breaking Changes\n"
    for i = 0; i < self.breaking_notes.length(); i = i + 1 {
      md = md + "- " + self.breaking_notes[i] + "\n"
    }
    md = md + "\n"
  }
  if self.non_breaking_notes.length() > 0 {
    md = md + "### ✨ Enhancements & Additions\n"
    for i = 0; i < self.non_breaking_notes.length(); i = i + 1 {
      md = md + "- " + self.non_breaking_notes[i] + "\n"
    }
    md = md + "\n"
  }
  md
}
