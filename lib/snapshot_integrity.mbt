// Structural integrity checks before snapshots enter governance evaluation.

///|
pub(all) struct SnapshotIntegrityIssue {
  code : String
  message : String
  index : Int
} derive(Debug, Eq)

///|
pub(all) struct SnapshotIntegrityReport {
  checked_count : Int
  issues : Array[SnapshotIntegrityIssue]
} derive(Debug, Eq)

///|
fn integrity_issue(
  issues : Array[SnapshotIntegrityIssue],
  code : String,
  message : String,
  index : Int,
) -> Unit {
  issues.push({ code, message, index })
}

///|
pub fn validate_snapshot_integrity(
  snapshots : Array[SchemaSnapshot],
) -> SnapshotIntegrityReport {
  let issues : Array[SnapshotIntegrityIssue] = []
  for index, snapshot in snapshots {
    if snapshot.subject.length() == 0 {
      integrity_issue(
        issues, "EMPTY_SUBJECT", "snapshot subject is empty", index,
      )
    }
    if snapshot.schema.id != snapshot.subject {
      integrity_issue(
        issues, "SUBJECT_ID_MISMATCH", "snapshot subject differs from schema id",
        index,
      )
    }
    if @types.SemVer::parse(snapshot.schema.version) is None {
      integrity_issue(
        issues, "INVALID_VERSION", "snapshot version is invalid", index,
      )
    }
    if snapshot.schema.owner.length() == 0 {
      integrity_issue(issues, "EMPTY_OWNER", "schema owner is empty", index)
    }
    if snapshot.source.length() == 0 {
      integrity_issue(issues, "EMPTY_SOURCE", "snapshot source is empty", index)
    }
    if snapshot.created_at.length() == 0 {
      integrity_issue(
        issues, "EMPTY_CREATED_AT", "snapshot timestamp is empty", index,
      )
    }
    if snapshot.status == Revoked && snapshot.source.length() == 0 {
      integrity_issue(
        issues, "REVOKED_SOURCE_REQUIRED", "revoked snapshots must retain their source evidence",
        index,
      )
    }
  }
  { checked_count: snapshots.length(), issues }
}

///|
pub fn SnapshotIntegrityReport::is_healthy(
  self : SnapshotIntegrityReport,
) -> Bool {
  self.issues.length() == 0
}

///|
pub fn SnapshotIntegrityReport::to_markdown(
  self : SnapshotIntegrityReport,
) -> String {
  let mut output = "# Snapshot Integrity Report\n\n"
  output = output + "Checked: " + self.checked_count.to_string() + "\n"
  output = output + "Issues: " + self.issues.length().to_string() + "\n\n"
  if self.issues.length() == 0 {
    output + "No integrity issues.\n"
  } else {
    output = output + "| Index | Code | Message |\n| ---: | :--- | :--- |\n"
    for issue in self.issues {
      output = output +
        "| " +
        issue.index.to_string() +
        " | `" +
        issue.code +
        "` | " +
        issue.message +
        " |\n"
    }
    output
  }
}

///|
pub fn SnapshotIntegrityReport::to_json(
  self : SnapshotIntegrityReport,
) -> String {
  let mut output = "{\"checked_count\":" +
    self.checked_count.to_string() +
    ",\"issues\":["
  for i, issue in self.issues {
    if i > 0 {
      output = output + ","
    }
    output = output +
      "{\"index\":" +
      issue.index.to_string() +
      ",\"code\":\"" +
      json_escape(issue.code) +
      "\",\"message\":\"" +
      json_escape(issue.message) +
      "\"}"
  }
  output + "]}"
}
