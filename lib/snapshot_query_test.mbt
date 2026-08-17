///|
fn query_fixture_schema(
  version : String,
  status : SnapshotStatus,
) -> SchemaSnapshot {
  SchemaSnapshot::new(
    "orders",
    Schema::new("orders", "Orders", version, "query-test", []),
    source="query-test",
    status~,
  )
}

///|
test "snapshot queries select a validated version range" {
  let store = SnapshotStore::new()
  ignore(store.insert(query_fixture_schema("1.0.0", Active)))
  ignore(store.insert(query_fixture_schema("1.1.0", Active)))
  ignore(store.insert(query_fixture_schema("2.0.0", Active)))
  let selected = query_snapshots(
    store,
    SnapshotQuery::new("orders", from_version="1.1.0", to_version="2.0.0"),
  )
  assert_true(selected is Ok(_))
  match selected {
    Ok(items) => assert_eq(items.length(), 2)
    Err(_) => assert_true(false)
  }
}

///|
test "snapshot queries reject invalid ranges and hide revoked snapshots" {
  let store = SnapshotStore::new()
  ignore(store.insert(query_fixture_schema("1.0.0", Active)))
  ignore(store.insert(query_fixture_schema("1.1.0", Revoked)))
  let invalid = query_snapshots(
    store,
    SnapshotQuery::new("orders", from_version="not-semver"),
  )
  assert_true(invalid is Err(_))
  let visible = query_snapshots(store, SnapshotQuery::new("orders"))
  match visible {
    Ok(items) => assert_eq(items.length(), 1)
    Err(_) => assert_true(false)
  }
}
