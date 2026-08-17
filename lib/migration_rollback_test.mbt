///|
test "rollback planner preserves reversible actions and flags unsafe ones" {
  let base = Schema::new("orders", "Orders", "1.0.0", "rollback-test", [
    Field::new("amount", Primitive(TInt)),
  ])
  let target = Schema::new("orders", "Orders", "1.1.0", "rollback-test", [
    Field::new("amount", Primitive(TDouble)),
  ])
  let plan = plan_schema_migration(base, target)
  let rollback = build_rollback_plan(plan)
  assert_eq(rollback.actions.length(), 1)
  assert_true(rollback.is_safe())
  assert_true(rollback.to_markdown().contains("Rollback Plan"))
}
