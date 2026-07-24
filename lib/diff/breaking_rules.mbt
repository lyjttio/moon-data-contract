// MoonBit Data Contract - Detailed Breaking Change Rule Classifier

pub(all) enum BreakingCategory {
  CategoryFieldDeletion
  CategoryTypeIncompatibility
  CategoryConstraintTightened
  CategoryRequiredFieldAdded
  CategoryEnumVariantRemoved
  CategoryPrimaryKeyModified
} derive(Debug, Eq)

pub(all) struct BreakingRuleViolation {
  rule_code : String
  category : BreakingCategory
  field_name : String
  reason : String
} derive(Debug, Eq)

pub fn classify_breaking_change(
  field_name : String,
  old_type : DataType,
  new_type : DataType
) -> BreakingRuleViolation? {
  if old_type != new_type {
    Some({
      rule_code: "BRK-001",
      category: CategoryTypeIncompatibility,
      field_name,
      reason: "Type changed from " + old_type.to_string() + " to " + new_type.to_string(),
    })
  } else {
    None
  }
}

pub fn check_enum_shrinking(
  field_name : String,
  old_enums : Array[String],
  new_enums : Array[String]
) -> Array[BreakingRuleViolation] {
  let violations : Array[BreakingRuleViolation] = []
  for i = 0; i < old_enums.length(); i = i + 1 {
    let item = old_enums[i]
    let mut found = false
    for j = 0; j < new_enums.length(); j = j + 1 {
      if new_enums[j] == item {
        found = true
        break
      }
    }
    if !found {
      violations.push({
        rule_code: "BRK-002",
        category: CategoryEnumVariantRemoved,
        field_name,
        reason: "Enum variant '" + item + "' was removed from allowed set",
      })
    }
  }
  violations
}
