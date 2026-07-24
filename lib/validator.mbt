// MoonBit Data Contract & Schema Evolution Tool - Data Contract Validator Engine

pub(all) enum FieldValue {
  VBool(Bool)
  VInt(Int)
  VDouble(Double)
  VString(String)
  VNull
} derive(Debug, Eq)

pub fn validate_field_value(field : Field, value : FieldValue?) -> Array[ValidationError] {
  let errors : Array[ValidationError] = []

  match value {
    None | Some(VNull) => {
      if field.required {
        errors.push({
          field: field.name,
          message: "Field '" + field.name + "' is required but missing or null",
          code: "MISSING_REQUIRED_FIELD",
        })
      }
      if field.primary_key {
        errors.push({
          field: field.name,
          message: "Primary key field '" + field.name + "' cannot be null or empty",
          code: "INVALID_PRIMARY_KEY",
        })
      }
    }
    Some(val) => {
      // Type checking
      match (field.field_type, val) {
        (Primitive(TBool), VBool(_)) => ()
        (Primitive(TInt), VInt(_)) => ()
        (Primitive(TDouble), VDouble(_)) => ()
        (Primitive(TDouble), VInt(_)) => () // Implicit widening allowed
        (Primitive(TString), VString(_)) => ()
        (OptionalDef(_), _) => ()
        _ => {
          errors.push({
            field: field.name,
            message: "Field '" + field.name + "' type mismatch",
            code: "TYPE_MISMATCH",
          })
        }
      }

      // Numerical range check
      match val {
        VInt(v) => {
          let double_v = v.to_double()
          match field.constraint.min_value {
            Some(min_v) => {
              if double_v < min_v {
                errors.push({
                  field: field.name,
                  message: "Field '" + field.name + "' value is below min threshold " + min_v.to_string(),
                  code: "VALUE_OUT_OF_RANGE",
                })
              }
            }
            None => ()
          }
          match field.constraint.max_value {
            Some(max_v) => {
              if double_v > max_v {
                errors.push({
                  field: field.name,
                  message: "Field '" + field.name + "' value exceeds max threshold " + max_v.to_string(),
                  code: "VALUE_OUT_OF_RANGE",
                })
              }
            }
            None => ()
          }
        }
        VDouble(double_v) => {
          match field.constraint.min_value {
            Some(min_v) => {
              if double_v < min_v {
                errors.push({
                  field: field.name,
                  message: "Field '" + field.name + "' value is below min threshold " + min_v.to_string(),
                  code: "VALUE_OUT_OF_RANGE",
                })
              }
            }
            None => ()
          }
          match field.constraint.max_value {
            Some(max_v) => {
              if double_v > max_v {
                errors.push({
                  field: field.name,
                  message: "Field '" + field.name + "' value exceeds max threshold " + max_v.to_string(),
                  code: "VALUE_OUT_OF_RANGE",
                })
              }
            }
            None => ()
          }
        }
        VString(str_v) => {
          match field.constraint.allowed_values {
            Some(allowed) => {
              let mut found = false
              for i = 0; i < allowed.length(); i = i + 1 {
                if allowed[i] == str_v {
                  found = true
                }
              }
              if !found {
                errors.push({
                  field: field.name,
                  message: "Field '" + field.name + "' value '" + str_v + "' is not in allowed values",
                  code: "INVALID_ENUM_VALUE",
                })
              }
            }
            None => ()
          }
        }
        _ => ()
      }
    }
  }

  errors
}

pub fn validate_schema_payload(
  schema : Schema,
  payload : Map[String, FieldValue]
) -> ValidationResult {
  let all_errors : Array[ValidationError] = []

  for i = 0; i < schema.fields.length(); i = i + 1 {
    let field = schema.fields[i]
    let val = payload.get(field.name)
    let field_errors = validate_field_value(field, val)
    for j = 0; j < field_errors.length(); j = j + 1 {
      all_errors.push(field_errors[j])
    }
  }

  if all_errors.length() == 0 {
    ValidationResult::ok()
  } else {
    ValidationResult::fail(all_errors)
  }
}
