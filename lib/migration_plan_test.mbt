///|
fn migration_base_schema() -> Schema {
  Schema::new("orders", "Orders", "1.0.0", "fixture", [
    Field::new("id", Primitive(TInt), primary_key=true),
  ])
}

///|
test "migration plan marks optional additions automatic and reversible" {
  let base = migration_base_schema()
  let target = Schema::new("orders", "Orders", "1.1.0", "fixture", [
    base.fields[0],
    Field::new("email", Primitive(TString), required=false),
  ])
  let plan = plan_schema_migration(base, target)
  assert_eq(plan.automatic_action_count(), 1)
  assert_eq(plan.manual_action_count(), 0)
  assert_true(plan.is_reversible())
  assert_eq(plan.actions[0].kind, MigrationActionKind::AddOptionalField)
}

///|
test "migration plan requires review for required additions" {
  let base = migration_base_schema()
  let target = Schema::new("orders", "Orders", "1.1.0", "fixture", [
    base.fields[0],
    Field::new("account_id", Primitive(TString)),
  ])
  let plan = plan_schema_migration(base, target)
  assert_eq(plan.manual_action_count(), 1)
  assert_false(plan.is_reversible())
  assert_true(check_rollback(plan).length() >= 1)
  assert_eq(plan.actions[0].safety, MigrationSafety::Manual)
}

///|
test "migration plan classifies type narrowing as unsafe" {
  let base = Schema::new("orders", "Orders", "1.0.0", "fixture", [
    Field::new("amount", Primitive(TDouble)),
  ])
  let target = Schema::new("orders", "Orders", "2.0.0", "fixture", [
    Field::new("amount", Primitive(TInt)),
  ])
  let plan = plan_schema_migration(base, target)
  assert_eq(plan.actions[0].kind, MigrationActionKind::NarrowType)
  assert_eq(plan.actions[0].safety, MigrationSafety::Unsafe)
}
