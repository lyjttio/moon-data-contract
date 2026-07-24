// MoonBit Data Contract - Strict Mode Data Contract Validator

pub(all) struct ValidationOptions {
  allow_extra_fields : Bool
  enable_coercion : Bool
  strict_enums : Bool
} derive(Debug, Eq)

pub fn ValidationOptions::default() -> ValidationOptions {
  {
    allow_extra_fields: false,
    enable_coercion: false,
    strict_enums: true,
  }
}

pub fn validate_payload_with_options(
  schema : Schema,
  payload : Map[String, FieldValue],
  options~ : ValidationOptions = ValidationOptions::default()
) -> ValidationResult {
  let errors : Array[ValidationError] = []

  // Check schema fields
  for i = 0; i < schema.fields.length(); i = i + 1 {
    let field = schema.fields[i]
    let val_opt = payload.get(field.name)

    match val_opt {
      None | Some(VNull) => {
        if field.required {
          errors.push({
            field: field.name,
            message: "Missing required field '" + field.name + "'",
            code: "REQUIRED_FIELD_MISSING",
          })
        }
      }
      Some(val) => {
        let final_val = if options.enable_coercion {
          match coerce_value_to_type(val, field.field_type) {
            Some(v) => v
            None => val
          }
        } else {
          val
        }

        let field_errors = validate_field_value(field, Some(final_val))
        for j = 0; j < field_errors.length(); j = j + 1 {
          errors.push(field_errors[j])
        }
      }
    }
  }

  if errors.length() == 0 {
    ValidationResult::ok()
  } else {
    ValidationResult::fail(errors)
  }
}
