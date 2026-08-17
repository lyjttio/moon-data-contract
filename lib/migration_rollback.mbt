// Explicit reverse-operation plans for safe migration rehearsals.

///|
pub(all) struct RollbackAction {
  field_name : String
  reverse_kind : MigrationActionKind
  safe : Bool
  reason : String
} derive(Debug, Eq)

///|
pub(all) struct RollbackPlan {
  source_version : String
  target_version : String
  actions : Array[RollbackAction]
  issues : Array[String]
} derive(Debug, Eq)

///|
fn reverse_kind(kind : MigrationActionKind) -> MigrationActionKind? {
  match kind {
    AddOptionalField => Some(RemoveField)
    RelaxRequired => Some(AddRequiredField)
    WidenType => Some(NarrowType)
    _ => None
  }
}

///|
pub fn build_rollback_plan(plan : MigrationPlan) -> RollbackPlan {
  let actions : Array[RollbackAction] = []
  let issues : Array[String] = []
  for action in plan.actions {
    match reverse_kind(action.kind) {
      Some(kind) =>
        if action.reversible {
          actions.push({
            field_name: action.field_name,
            reverse_kind: kind,
            safe: true,
            reason: "reverse operation is defined by the migration action",
          })
        } else {
          issues.push(action.field_name + ":ACTION_MARKED_IRREVERSIBLE")
        }
      None => issues.push(action.field_name + ":NO_REVERSE_OPERATION")
    }
  }
  {
    source_version: plan.target_version,
    target_version: plan.base_version,
    actions,
    issues,
  }
}

///|
pub fn RollbackPlan::is_safe(self : RollbackPlan) -> Bool {
  if self.issues.length() > 0 {
    return false
  }
  for action in self.actions {
    if !action.safe {
      return false
    }
  }
  true
}

///|
pub fn RollbackPlan::to_markdown(self : RollbackPlan) -> String {
  let mut output = "# Rollback Plan\n\n"
  output = output + "- Source: `" + self.source_version + "`\n"
  output = output + "- Target: `" + self.target_version + "`\n"
  output = output + "- Safe: " + self.is_safe().to_string() + "\n"
  output = output + "- Issues: " + self.issues.length().to_string() + "\n\n"
  if self.actions.length() > 0 {
    output = output + "| Field | Reverse action | Safe | Reason |\n"
    output = output + "| :--- | :--- | :---: | :--- |\n"
    for action in self.actions {
      output = output +
        "| `" +
        action.field_name +
        "` | `" +
        migration_kind_text(action.reverse_kind) +
        "` | " +
        action.safe.to_string() +
        " | " +
        action.reason +
        " |\n"
    }
  }
  if self.issues.length() > 0 {
    output = output + "\n## Issues\n\n"
    for issue in self.issues {
      output = output + "- " + issue + "\n"
    }
  }
  output
}

///|
pub fn rollback_plan_summary(plan : RollbackPlan) -> String {
  "source=" +
  plan.source_version +
  ", target=" +
  plan.target_version +
  ", actions=" +
  plan.actions.length().to_string() +
  ", issues=" +
  plan.issues.length().to_string() +
  ", safe=" +
  plan.is_safe().to_string()
}
