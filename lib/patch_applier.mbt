// MoonBit Data Contract - Programmatic Schema Patch & Transformation Applier

///|
pub(all) enum SchemaPatchOp {
  OpAddField(Field)
  OpRemoveField(String)
  OpUpdateFieldType(String, DataType)
  OpUpdateFieldRequired(String, Bool)
} derive(Debug, Eq)

///|
pub(all) struct SchemaPatch {
  target_schema_id : String
  target_version : String
  operations : Array[SchemaPatchOp]
} derive(Debug, Eq)

///|
pub fn apply_patch_to_schema(schema : Schema, patch : SchemaPatch) -> Schema {
  let updated_fields : Array[Field] = []

  for i = 0; i < schema.fields.length(); i = i + 1 {
    let f = schema.fields[i]
    let mut current_field = f
    let mut is_removed = false

    for j = 0; j < patch.operations.length(); j = j + 1 {
      let op = patch.operations[j]
      match op {
        OpRemoveField(name) =>
          if current_field.name == name {
            is_removed = true
          }
        OpUpdateFieldType(name, new_type) =>
          if current_field.name == name {
            current_field = Field::new(
              current_field.name,
              new_type,
              required=current_field.required,
              primary_key=current_field.primary_key,
              description=current_field.description,
              constraint=current_field.constraint,
            )
          }
        OpUpdateFieldRequired(name, req) =>
          if current_field.name == name {
            current_field = Field::new(
              current_field.name,
              current_field.field_type,
              required=req,
              primary_key=current_field.primary_key,
              description=current_field.description,
              constraint=current_field.constraint,
            )
          }
        _ => ()
      }
    }

    if !is_removed {
      updated_fields.push(current_field)
    }
  }

  // Add new fields from OpAddField
  for j = 0; j < patch.operations.length(); j = j + 1 {
    let op = patch.operations[j]
    match op {
      OpAddField(new_f) => {
        let mut exists = false
        for k = 0; k < updated_fields.length(); k = k + 1 {
          if updated_fields[k].name == new_f.name {
            exists = true
            break
          }
        }
        if !exists {
          updated_fields.push(new_f)
        }
      }
      _ => ()
    }
  }

  Schema::new(
    schema.id,
    schema.name,
    patch.target_version,
    schema.owner,
    updated_fields,
  )
}
