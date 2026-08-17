///|
test "migration plans expose summaries and deterministic formats" {
  let base = Schema::new("orders", "Orders", "1.0.0", "render-test", [])
  let target = Schema::new("orders", "Orders", "1.1.0", "render-test", [
    Field::new("id", Primitive(TInt), required=false),
  ])
  let plan = plan_schema_migration(base, target)
  let summary = plan.summary()
  assert_eq(summary.action_count, 1)
  assert_eq(summary.automatic_count, 1)
  assert_true(plan.to_markdown().contains("Migration Plan"))
  assert_true(plan.to_json().contains("add_optional_field"))
  assert_eq(plan.to_markdown(), plan.to_markdown())
}

///|
test "migration batch renderer includes rollback evidence" {
  let base = Schema::new("orders", "Orders", "1.0.0", "render-test", [])
  let target = Schema::new("orders", "Orders", "1.1.0", "render-test", [
    Field::new("id", Primitive(TString), required=true),
  ])
  let plan = plan_schema_migration(base, target)
  assert_eq(plan.summary().rollback_issue_count, 1)
  let batch = render_migration_batch([plan])
  assert_true(batch.contains("rollback issues"))
  assert_true(batch.contains("1.0.0"))
}
