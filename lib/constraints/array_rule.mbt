// MoonBit Data Contract - Array Constraint Evaluator

///|
pub(all) struct ArrayRule {
  min_items : Int?
  max_items : Int?
  unique_items : Bool
} derive(Debug, Eq)

///|
pub fn ArrayRule::default() -> ArrayRule {
  { min_items: None, max_items: None, unique_items: false }
}

///|
pub fn check_array_rule(
  field_name : String,
  items : Array[String],
  rule : ArrayRule,
) -> Array[ConstraintViolation] {
  let violations : Array[ConstraintViolation] = []

  match rule.min_items {
    Some(min_n) =>
      if items.length() < min_n {
        violations.push(
          ConstraintViolation::new(
            field_name,
            "MIN_ITEMS_VIOLATION",
            "Array item count " +
            items.length().to_string() +
            " is less than minimum " +
            min_n.to_string(),
          ),
        )
      }
    None => ()
  }

  match rule.max_items {
    Some(max_n) =>
      if items.length() > max_n {
        violations.push(
          ConstraintViolation::new(
            field_name,
            "MAX_ITEMS_VIOLATION",
            "Array item count " +
            items.length().to_string() +
            " exceeds maximum " +
            max_n.to_string(),
          ),
        )
      }
    None => ()
  }

  if rule.unique_items {
    for i = 0; i < items.length(); i = i + 1 {
      for j = i + 1; j < items.length(); j = j + 1 {
        if items[i] == items[j] {
          violations.push(
            ConstraintViolation::new(
              field_name,
              "UNIQUE_ITEMS_VIOLATION",
              "Duplicate item '" + items[i] + "' found in unique array",
            ),
          )
          break
        }
      }
    }
  }

  violations
}
