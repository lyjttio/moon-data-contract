// Migration actions derived from real Schema Diff entries.

///|
pub(all) enum MigrationActionKind {
  AddOptionalField
  AddRequiredField
  RemoveField
  WidenType
  NarrowType
  ChangeType
  RelaxRequired
  ChangeConstraint
} derive(Debug, Eq)

///|
pub(all) enum MigrationSafety {
  Automatic
  Manual
  Unsafe
} derive(Debug, Eq)

///|
pub(all) struct MigrationAction {
  field_name : String
  kind : MigrationActionKind
  safety : MigrationSafety
  reversible : Bool
  reason : String
} derive(Debug, Eq)

///|
pub(all) struct MigrationPlan {
  base_version : String
  target_version : String
  actions : Array[MigrationAction]
} derive(Debug, Eq)

///|
pub fn MigrationPlan::automatic_action_count(self : MigrationPlan) -> Int {
  let mut count = 0
  for action in self.actions {
    if action.safety == Automatic {
      count = count + 1
    }
  }
  count
}

///|
pub fn MigrationPlan::manual_action_count(self : MigrationPlan) -> Int {
  let mut count = 0
  for action in self.actions {
    if action.safety != Automatic {
      count = count + 1
    }
  }
  count
}

///|
pub fn MigrationPlan::is_reversible(self : MigrationPlan) -> Bool {
  for action in self.actions {
    if !action.reversible {
      return false
    }
  }
  true
}
