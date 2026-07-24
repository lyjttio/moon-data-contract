// MoonBit Data Contract - String Pattern & Format Evaluator

///|
pub fn is_valid_email(s : String) -> Bool {
  let mut at_idx = -1
  for i = 0; i < s.length(); i = i + 1 {
    if s[i] == '@' {
      at_idx = i
      break
    }
  }
  if at_idx > 0 && at_idx < s.length() - 1 {
    let domain = s[at_idx + 1:s.length()].to_owned()
    let mut dot_found = false
    for i = 0; i < domain.length(); i = i + 1 {
      if domain[i] == '.' {
        dot_found = true
        break
      }
    }
    dot_found
  } else {
    false
  }
}

///|
pub fn is_valid_uuid(s : String) -> Bool {
  if s.length() != 36 {
    return false
  }
  for i = 0; i < 36; i = i + 1 {
    let ch = s[i]
    if i == 8 || i == 13 || i == 18 || i == 23 {
      if ch != '-' {
        return false
      }
    } else {
      let is_hex = (ch >= '0' && ch <= '9') ||
        (ch >= 'a' && ch <= 'f') ||
        (ch >= 'A' && ch <= 'F')
      if !is_hex {
        return false
      }
    }
  }
  true
}

///|
pub fn is_valid_ipv4(s : String) -> Bool {
  let parts : Array[String] = []
  let mut start_idx = 0
  for i = 0; i < s.length(); i = i + 1 {
    if s[i] == '.' {
      if i > start_idx {
        parts.push(s[start_idx:i].to_owned())
      }
      start_idx = i + 1
    }
  }
  if s.length() > start_idx {
    parts.push(s[start_idx:s.length()].to_owned())
  }
  if parts.length() != 4 {
    return false
  }
  for i = 0; i < 4; i = i + 1 {
    let p = parts[i]
    if p.length() == 0 || p.length() > 3 {
      return false
    }
    for j = 0; j < p.length(); j = j + 1 {
      if p[j] < '0' || p[j] > '9' {
        return false
      }
    }
  }
  true
}

///|
pub fn check_string_rule(
  field_name : String,
  val : String,
  rule : @types.StringRule,
) -> Array[ConstraintViolation] {
  let violations : Array[ConstraintViolation] = []

  match rule.min_length {
    Some(min_len) =>
      if val.length() < min_len {
        violations.push(
          ConstraintViolation::new(
            field_name,
            "MIN_LENGTH_VIOLATION",
            "String length " +
            val.length().to_string() +
            " is shorter than minimum " +
            min_len.to_string(),
          ),
        )
      }
    None => ()
  }

  match rule.max_length {
    Some(max_len) =>
      if val.length() > max_len {
        violations.push(
          ConstraintViolation::new(
            field_name,
            "MAX_LENGTH_VIOLATION",
            "String length " +
            val.length().to_string() +
            " exceeds maximum " +
            max_len.to_string(),
          ),
        )
      }
    None => ()
  }

  match rule.format_kind {
    Some("email") =>
      if !is_valid_email(val) {
        violations.push(
          ConstraintViolation::new(
            field_name,
            "INVALID_EMAIL_FORMAT",
            "Value '" + val + "' is not a valid email address",
          ),
        )
      }
    Some("uuid") =>
      if !is_valid_uuid(val) {
        violations.push(
          ConstraintViolation::new(
            field_name,
            "INVALID_UUID_FORMAT",
            "Value '" + val + "' is not a valid UUID string",
          ),
        )
      }
    Some("ipv4") =>
      if !is_valid_ipv4(val) {
        violations.push(
          ConstraintViolation::new(
            field_name,
            "INVALID_IPV4_FORMAT",
            "Value '" + val + "' is not a valid IPv4 address",
          ),
        )
      }
    _ => ()
  }

  violations
}
