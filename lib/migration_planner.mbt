// Deterministic migration plan generation.

///|
fn primitive_type_action(
  field_name : String,
  old_type : DataType,
  new_type : DataType,
) -> MigrationAction {
  match (old_type, new_type) {
    (Primitive(TInt), Primitive(TDouble)) =>
      {
        field_name,
        kind: WidenType,
        safety: Automatic,
        reversible: true,
        reason: "Integer values can be widened to double",
      }
    (Primitive(TDouble), Primitive(TInt)) =>
      {
        field_name,
        kind: NarrowType,
        safety: Unsafe,
        reversible: false,
        reason: "Double values may lose fractional precision",
      }
    _ =>
      {
        field_name,
        kind: ChangeType,
        safety: Manual,
        reversible: false,
        reason: "Type conversion requires an explicit migration",
      }
  }
}

///|
fn action_for_diff(diff : DiffEntry) -> MigrationAction {
  match diff.kind {
    FieldAdded(field) =>
      if field.required {
        {
          field_name: diff.field_name,
          kind: AddRequiredField,
          safety: Manual,
          reversible: false,
          reason: "Required field needs a default or a backfill",
        }
      } else {
        {
          field_name: diff.field_name,
          kind: AddOptionalField,
          safety: Automatic,
          reversible: true,
          reason: "Optional field can be added without changing existing payloads",
        }
      }
    FieldRemoved(_) =>
      {
        field_name: diff.field_name,
        kind: RemoveField,
        safety: Manual,
        reversible: false,
        reason: "Removing a field may discard downstream data",
      }
    TypeChanged(old_type, new_type) =>
      primitive_type_action(diff.field_name, old_type, new_type)
    RequiredChanged(_, required) =>
      if required {
        {
          field_name: diff.field_name,
          kind: AddRequiredField,
          safety: Manual,
          reversible: false,
          reason: "Making a field required needs a payload backfill",
        }
      } else {
        {
          field_name: diff.field_name,
          kind: RelaxRequired,
          safety: Automatic,
          reversible: true,
          reason: "Relaxing a required field is backward compatible",
        }
      }
    ConstraintChanged(_, _) =>
      {
        field_name: diff.field_name,
        kind: ChangeConstraint,
        safety: Manual,
        reversible: false,
        reason: "Constraint changes require data-range verification",
      }
  }
}

///|
fn migration_action_before(
  left : MigrationAction,
  right : MigrationAction,
) -> Bool {
  if left.field_name != right.field_name {
    left.field_name < right.field_name
  } else {
    left.reason < right.reason
  }
}

///|
pub fn plan_schema_migration(base : Schema, target : Schema) -> MigrationPlan {
  let diffs = diff_schemas(base, target)
  let actions : Array[MigrationAction] = []
  for diff in diffs {
    let action = action_for_diff(diff)
    let next : Array[MigrationAction] = []
    let mut inserted = false
    for existing in actions {
      if !inserted && migration_action_before(action, existing) {
        next.push(action)
        inserted = true
      }
      next.push(existing)
    }
    if !inserted {
      next.push(action)
    }
    actions.clear()
    for item in next {
      actions.push(item)
    }
  }
  { base_version: base.version, target_version: target.version, actions }
}

///|
pub fn check_rollback(plan : MigrationPlan) -> Array[String] {
  let issues : Array[String] = []
  for action in plan.actions {
    if !action.reversible {
      let code = match action.kind {
        AddRequiredField => "REQUIRED_FIELD_NO_DEFAULT"
        RemoveField => "REMOVED_DATA_CANNOT_BE_RESTORED"
        NarrowType => "NARROWING_LOSES_INFORMATION"
        _ => "MANUAL_MIGRATION_REQUIRED"
      }
      issues.push(action.field_name + ":" + code)
    }
  }
  issues
}
