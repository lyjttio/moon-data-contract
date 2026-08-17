// Deterministic snapshot storage and version-chain analysis.

///|
pub fn SnapshotStore::new() -> SnapshotStore {
  { snapshots: Map([]) }
}

///|
fn snapshot_before(left : SchemaSnapshot, right : SchemaSnapshot) -> Bool {
  match
    (
      @types.SemVer::parse(left.schema.version),
      @types.SemVer::parse(right.schema.version),
    ) {
    (Some(left_version), Some(right_version)) =>
      left_version.compare(right_version) < 0
    (Some(_), None) => true
    _ => false
  }
}

///|
fn sorted_snapshots(snapshots : Array[SchemaSnapshot]) -> Array[SchemaSnapshot] {
  let sorted : Array[SchemaSnapshot] = []
  for snapshot in snapshots {
    let next : Array[SchemaSnapshot] = []
    let mut inserted = false
    for existing in sorted {
      if !inserted && snapshot_before(snapshot, existing) {
        next.push(snapshot)
        inserted = true
      }
      next.push(existing)
    }
    if !inserted {
      next.push(snapshot)
    }
    sorted.clear()
    for item in next {
      sorted.push(item)
    }
  }
  sorted
}

///|
pub fn SnapshotStore::insert(
  self : SnapshotStore,
  snapshot : SchemaSnapshot,
) -> Result[Unit, String] {
  if snapshot.subject.length() == 0 {
    return Err("Snapshot subject cannot be empty")
  }
  match @types.SemVer::parse(snapshot.schema.version) {
    None => return Err("Snapshot version is not valid SemVer")
    Some(_) => ()
  }
  match self.snapshots.get(snapshot.subject) {
    None => {
      self.snapshots.set(snapshot.subject, [snapshot])
      Ok(())
    }
    Some(existing) => {
      for item in existing {
        if item.schema.version == snapshot.schema.version {
          return Err("Snapshot version already exists")
        }
      }
      existing.push(snapshot)
      let ordered = sorted_snapshots(existing)
      self.snapshots.set(snapshot.subject, ordered)
      Ok(())
    }
  }
}

///|
pub fn SnapshotStore::get(
  self : SnapshotStore,
  subject : String,
  version : String,
) -> SchemaSnapshot? {
  match self.snapshots.get(subject) {
    None => None
    Some(items) => {
      for item in items {
        if item.schema.version == version {
          return Some(item)
        }
      }
      None
    }
  }
}

///|
pub fn SnapshotStore::list(
  self : SnapshotStore,
  subject : String,
) -> Array[SchemaSnapshot] {
  match self.snapshots.get(subject) {
    None => []
    Some(items) => sorted_snapshots(items)
  }
}

///|
pub fn SnapshotStore::latest(
  self : SnapshotStore,
  subject : String,
) -> SchemaSnapshot? {
  let items = self.list(subject)
  if items.length() == 0 {
    None
  } else {
    Some(items[items.length() - 1])
  }
}

///|
fn is_next_version(previous : @types.SemVer, current : @types.SemVer) -> Bool {
  current.to_string() == previous.bump_patch().to_string() ||
  current.to_string() == previous.bump_minor().to_string() ||
  current.to_string() == previous.bump_major().to_string()
}

///|
pub fn analyze_snapshot_chain(
  snapshots : Array[SchemaSnapshot],
) -> SnapshotChainReport {
  let ordered = sorted_snapshots(snapshots)
  let versions : Array[String] = []
  let issues : Array[SnapshotChainIssue] = []
  let mut previous : @types.SemVer? = None
  for snapshot in ordered {
    match @types.SemVer::parse(snapshot.schema.version) {
      None =>
        issues.push({
          code: "INVALID_VERSION",
          message: "Snapshot version is not valid SemVer",
          version: snapshot.schema.version,
        })
      Some(current) =>
        if versions.length() > 0 &&
          versions[versions.length() - 1] == snapshot.schema.version {
          issues.push({
            code: "DUPLICATE_VERSION",
            message: "Snapshot version appears more than once",
            version: snapshot.schema.version,
          })
        } else {
          match previous {
            Some(before) =>
              if !is_next_version(before, current) {
                issues.push({
                  code: "VERSION_GAP",
                  message: "Snapshot chain skips the next SemVer step",
                  version: snapshot.schema.version,
                })
              }
            None => ()
          }
          versions.push(snapshot.schema.version)
          previous = Some(current)
        }
    }
  }
  if versions.length() == 0 {
    issues.push({
      code: "EMPTY_CHAIN",
      message: "Snapshot chain has no valid versions",
      version: "",
    })
  }
  { ordered_versions: versions, issues }
}
