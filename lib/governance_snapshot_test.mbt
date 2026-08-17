///|
fn snapshot_fixture(version : String) -> Schema {
  Schema::new("orders", "Orders", version, "fixture", [
    Field::new("id", Primitive(TInt), primary_key=true),
  ])
}

///|
test "snapshot store rejects duplicate versions and returns latest" {
  let store = SnapshotStore::new()
  let s1 = SchemaSnapshot::new(
    "orders",
    snapshot_fixture("1.0.0"),
    source="fixture",
  )
  let s2 = SchemaSnapshot::new(
    "orders",
    snapshot_fixture("1.1.0"),
    source="fixture",
  )
  assert_true(store.insert(s1) is Ok(_))
  assert_true(store.insert(s2) is Ok(_))
  assert_true(store.insert(s2) is Err(_))
  match store.latest("orders") {
    Some(latest) => assert_eq(latest.schema.version, "1.1.0")
    None => assert_true(false)
  }
}

///|
test "snapshot store rejects invalid versions and reports empty subjects" {
  let store = SnapshotStore::new()
  let invalid = SchemaSnapshot::new(
    "orders",
    snapshot_fixture("not-a-semver"),
    source="fixture",
  )
  assert_true(store.insert(invalid) is Err(_))
  let report = analyze_snapshot_chain([])
  assert_eq(report.issues.length(), 1)
  assert_eq(report.issues[0].code, "EMPTY_CHAIN")
}

///|
test "snapshot chain analysis sorts versions and detects gaps" {
  let snapshots = [
    SchemaSnapshot::new("orders", snapshot_fixture("1.2.0"), source="fixture"),
    SchemaSnapshot::new("orders", snapshot_fixture("1.0.0"), source="fixture"),
    SchemaSnapshot::new("orders", snapshot_fixture("1.0.0"), source="fixture"),
  ]
  let report = analyze_snapshot_chain(snapshots)
  assert_eq(report.ordered_versions, ["1.0.0", "1.2.0"])
  assert_true(report.issues.length() >= 2)
}
