// MoonBit Data Contract - Recursive Complex Struct Validator

///|
pub fn validate_nested_struct(
  parent_name : String,
  fields : Array[Field],
  payload : Map[String, FieldValue],
) -> Array[ValidationError] {
  let errors : Array[ValidationError] = []

  for i = 0; i < fields.length(); i = i + 1 {
    let field = fields[i]
    let path = parent_name + "." + field.name
    let val_opt = payload.get(field.name)

    match val_opt {
      None | Some(VNull) =>
        if field.required {
          errors.push({
            field: path,
            message: "Nested required field '" + path + "' is missing",
            code: "NESTED_REQUIRED_MISSING",
          })
        }
      Some(val) => {
        let field_errors = validate_field_value(field, Some(val))
        for j = 0; j < field_errors.length(); j = j + 1 {
          errors.push({
            field: path,
            message: field_errors[j].message,
            code: field_errors[j].code,
          })
        }
      }
    }
  }

  errors
}
