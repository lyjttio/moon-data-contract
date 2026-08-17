// Range queries and status summaries for immutable schema snapshots.

///|
pub(all) struct SnapshotQuery {
  subject : String
  from_version : String
  to_version : String
  include_revoked : Bool
} derive(Debug, Eq)

///|
pub fn SnapshotQuery::new(
  subject : String,
  from_version? : String = "",
  to_version? : String = "",
  include_revoked? : Bool = false,
) -> SnapshotQuery {
  { subject, from_version, to_version, include_revoked }
}

///|
pub(all) struct SnapshotStatusCounts {
  draft : Int
  active : Int
  deprecated : Int
  revoked : Int
} derive(Debug, Eq)

///|
fn parse_query_version(
  version : String,
  label : String,
) -> Result[@types.SemVer?, String] {
  if version.length() == 0 {
    Ok(None)
  } else {
    match @types.SemVer::parse(version) {
      Some(parsed) => Ok(Some(parsed))
      None => Err(label + " is not valid SemVer")
    }
  }
}

///|
fn version_is_in_range(
  version : @types.SemVer,
  from_version : @types.SemVer?,
  to_version : @types.SemVer?,
) -> Bool {
  let after_start = match from_version {
    None => true
    Some(start) => version.compare(start) >= 0
  }
  let before_end = match to_version {
    None => true
    Some(end) => version.compare(end) <= 0
  }
  after_start && before_end
}

///|
pub fn query_snapshots(
  store : SnapshotStore,
  query : SnapshotQuery,
) -> Result[Array[SchemaSnapshot], String] {
  if query.subject.length() == 0 {
    return Err("Snapshot query subject cannot be empty")
  }
  let from_version = match
    parse_query_version(query.from_version, "from_version") {
    Err(message) => return Err(message)
    Ok(value) => value
  }
  let to_version = match parse_query_version(query.to_version, "to_version") {
    Err(message) => return Err(message)
    Ok(value) => value
  }
  match (from_version, to_version) {
    (Some(start), Some(end)) =>
      if start.compare(end) > 0 {
        return Err("Snapshot query range is reversed")
      }
    _ => ()
  }
  let result : Array[SchemaSnapshot] = []
  for snapshot in store.list(query.subject) {
    if !query.include_revoked && snapshot.status == SnapshotStatus::Revoked {
      continue
    }
    match @types.SemVer::parse(snapshot.schema.version) {
      Some(version) =>
        if version_is_in_range(version, from_version, to_version) {
          result.push(snapshot)
        }
      None => ()
    }
  }
  Ok(result)
}

///|
pub fn count_snapshot_statuses(
  snapshots : Array[SchemaSnapshot],
) -> SnapshotStatusCounts {
  let mut draft = 0
  let mut active = 0
  let mut deprecated = 0
  let mut revoked = 0
  for snapshot in snapshots {
    match snapshot.status {
      Draft => draft += 1
      Active => active += 1
      Deprecated => deprecated += 1
      Revoked => revoked += 1
    }
  }
  { draft, active, deprecated, revoked }
}

///|
pub fn snapshot_lineage(snapshots : Array[SchemaSnapshot]) -> Array[String] {
  let lines : Array[String] = []
  for snapshot in snapshots {
    let status = match snapshot.status {
      Draft => "DRAFT"
      Active => "ACTIVE"
      Deprecated => "DEPRECATED"
      Revoked => "REVOKED"
    }
    lines.push(
      snapshot.subject +
      "@" +
      snapshot.schema.version +
      " [" +
      status +
      "] from " +
      snapshot.source,
    )
  }
  lines
}

///|
pub fn snapshot_query_summary(
  store : SnapshotStore,
  subject : String,
) -> String {
  let snapshots = store.list(subject)
  let counts = count_snapshot_statuses(snapshots)
  "subject=" +
  subject +
  ", total=" +
  snapshots.length().to_string() +
  ", active=" +
  counts.active.to_string() +
  ", deprecated=" +
  counts.deprecated.to_string() +
  ", revoked=" +
  counts.revoked.to_string()
}
