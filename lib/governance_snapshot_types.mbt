// Immutable schema snapshots used by the offline governance pipeline.

///|
pub(all) enum SnapshotStatus {
  Draft
  Active
  Deprecated
  Revoked
} derive(Debug, Eq)

///|
pub(all) struct SchemaSnapshot {
  subject : String
  schema : Schema
  status : SnapshotStatus
  source : String
  created_at : String
} derive(Debug, Eq)

///|
pub fn SchemaSnapshot::new(
  subject : String,
  schema : Schema,
  source? : String = "",
  created_at? : String = "",
  status? : SnapshotStatus = Active,
) -> SchemaSnapshot {
  { subject, schema, status, source, created_at }
}

///|
pub(all) struct SnapshotChainIssue {
  code : String
  message : String
  version : String
} derive(Debug, Eq)

///|
pub(all) struct SnapshotChainReport {
  ordered_versions : Array[String]
  issues : Array[SnapshotChainIssue]
} derive(Debug, Eq)

///|
pub(all) struct SnapshotStore {
  snapshots : Map[String, Array[SchemaSnapshot]]
} derive(Debug, Eq)
