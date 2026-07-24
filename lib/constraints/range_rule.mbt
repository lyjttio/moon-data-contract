// MoonBit Data Contract - Numerical Range Constraint Evaluator

pub(all) struct ConstraintViolation {
  field_name : String
  code : String
  message : String
} derive(Debug, Eq)

pub fn ConstraintViolation::new(
  field_name : String,
  code : String,
  message : String
) -> ConstraintViolation {
  { field_name, code, message }
}

pub fn check_numeric_range(
  field_name : String,
  val : Double,
  rule : @types.NumericRange
) -> Array[ConstraintViolation] {
  let violations : Array[ConstraintViolation] = []

  match rule.min_value {
    Some(min_v) => {
      if rule.exclusive_min {
        if val <= min_v {
          violations.push(ConstraintViolation::new(
            field_name,
            "EXCLUSIVE_MIN_VIOLATION",
            "Value " + val.to_string() + " must be strictly greater than " + min_v.to_string(),
          ))
        }
      } else {
        if val < min_v {
          violations.push(ConstraintViolation::new(
            field_name,
            "MIN_VALUE_VIOLATION",
            "Value " + val.to_string() + " is below minimum allowed " + min_v.to_string(),
          ))
        }
      }
    }
    None => ()
  }

  match rule.max_value {
    Some(max_v) => {
      if rule.exclusive_max {
        if val >= max_v {
          violations.push(ConstraintViolation::new(
            field_name,
            "EXCLUSIVE_MAX_VIOLATION",
            "Value " + val.to_string() + " must be strictly less than " + max_v.to_string(),
          ))
        }
      } else {
        if val > max_v {
          violations.push(ConstraintViolation::new(
            field_name,
            "MAX_VALUE_VIOLATION",
            "Value " + val.to_string() + " exceeds maximum allowed " + max_v.to_string(),
          ))
        }
      }
    }
    None => ()
  }

  match rule.multiple_of {
    Some(mult) => {
      if mult > 0.0 {
        let rem = val - (val / mult).floor() * mult
        if rem > 0.000001 && (mult - rem) > 0.000001 {
          violations.push(ConstraintViolation::new(
            field_name,
            "MULTIPLE_OF_VIOLATION",
            "Value " + val.to_string() + " is not a multiple of " + mult.to_string(),
          ))
        }
      }
    }
    None => ()
  }

  violations
}
