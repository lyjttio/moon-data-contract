// Human and machine-readable migration plan summaries.

///|
pub(all) struct MigrationSummary {
  action_count : Int
  automatic_count : Int
  manual_count : Int
  unsafe_count : Int
  rollback_issue_count : Int
} derive(Debug, Eq)

///|
fn migration_kind_text(kind : MigrationActionKind) -> String {
  match kind {
    AddOptionalField => "add_optional_field"
    AddRequiredField => "add_required_field"
    RemoveField => "remove_field"
    WidenType => "widen_type"
    NarrowType => "narrow_type"
    ChangeType => "change_type"
    RelaxRequired => "relax_required"
    ChangeConstraint => "change_constraint"
  }
}

///|
fn migration_safety_text(safety : MigrationSafety) -> String {
  match safety {
    Automatic => "automatic"
    Manual => "manual"
    Unsafe => "unsafe"
  }
}

///|
pub fn MigrationPlan::summary(self : MigrationPlan) -> MigrationSummary {
  let mut automatic_count = 0
  let mut manual_count = 0
  let mut unsafe_count = 0
  for action in self.actions {
    match action.safety {
      Automatic => automatic_count += 1
      Manual => manual_count += 1
      Unsafe => unsafe_count += 1
    }
  }
  {
    action_count: self.actions.length(),
    automatic_count,
    manual_count,
    unsafe_count,
    rollback_issue_count: check_rollback(self).length(),
  }
}

///|
pub fn MigrationPlan::to_markdown(self : MigrationPlan) -> String {
  let summary = self.summary()
  let mut output = "# Migration Plan\n\n"
  output = output + "- Base: `" + self.base_version + "`\n"
  output = output + "- Target: `" + self.target_version + "`\n"
  output = output + "- Actions: " + summary.action_count.to_string() + "\n"
  output = output + "- Automatic: " + summary.automatic_count.to_string() + "\n"
  output = output + "- Manual: " + summary.manual_count.to_string() + "\n"
  output = output + "- Unsafe: " + summary.unsafe_count.to_string() + "\n"
  output = output +
    "- Rollback issues: " +
    summary.rollback_issue_count.to_string() +
    "\n\n"
  if self.actions.length() == 0 {
    output + "No migration actions.\n"
  } else {
    output = output + "| Field | Action | Safety | Reversible | Reason |\n"
    output = output + "| :--- | :--- | :--- | :---: | :--- |\n"
    for action in self.actions {
      output = output +
        "| `" +
        action.field_name +
        "` | `" +
        migration_kind_text(action.kind) +
        "` | " +
        migration_safety_text(action.safety) +
        " | " +
        action.reversible.to_string() +
        " | " +
        action.reason +
        " |\n"
    }
    output
  }
}

///|
pub fn MigrationPlan::to_json(self : MigrationPlan) -> String {
  let summary = self.summary()
  let mut output = "{\"base_version\":\"" +
    json_escape(self.base_version) +
    "\",\"target_version\":\"" +
    json_escape(self.target_version) +
    "\",\"action_count\":" +
    summary.action_count.to_string() +
    ",\"actions\":["
  for i, action in self.actions {
    if i > 0 {
      output = output + ","
    }
    output = output +
      "{\"field\":\"" +
      json_escape(action.field_name) +
      "\",\"kind\":\"" +
      migration_kind_text(action.kind) +
      "\",\"safety\":\"" +
      migration_safety_text(action.safety) +
      "\",\"reversible\":" +
      action.reversible.to_string() +
      ",\"reason\":\"" +
      json_escape(action.reason) +
      "\"}"
  }
  output + "]}"
}

///|
pub fn render_migration_batch(plans : Array[MigrationPlan]) -> String {
  let mut output = "# Migration Batch\n\n"
  let mut total_actions = 0
  let mut total_rollback_issues = 0
  for plan in plans {
    let summary = plan.summary()
    total_actions += summary.action_count
    total_rollback_issues += summary.rollback_issue_count
    output = output + plan.to_markdown() + "\n"
  }
  output +
  "Batch actions: " +
  total_actions.to_string() +
  "\nBatch rollback issues: " +
  total_rollback_issues.to_string() +
  "\n"
}
