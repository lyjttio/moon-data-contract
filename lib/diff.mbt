// MoonBit Data Contract & Schema Evolution Tool - Schema Version Diff Engine

pub fn find_field_by_name(fields : Array[Field], name : String) -> Field? {
  for i = 0; i < fields.length(); i = i + 1 {
    if fields[i].name == name {
      return Some(fields[i])
    }
  }
  None
}

pub fn diff_schemas(v1 : Schema, v2 : Schema) -> Array[DiffEntry] {
  let diffs : Array[DiffEntry] = []

  // Check added or updated fields in v2
  for i = 0; i < v2.fields.length(); i = i + 1 {
    let f2 = v2.fields[i]
    match find_field_by_name(v1.fields, f2.name) {
      None => {
        // Field added in v2
        let impact : ImpactLevel = if f2.required {
          Breaking
        } else {
          NonBreaking
        }
        diffs.push({
          field_name: f2.name,
          kind: FieldAdded(f2),
          impact,
          description: "Field '" + f2.name + "' added in v2 (required=" + f2.required.to_string() + ")",
        })
      }
      Some(f1) => {
        // Check type change
        if f1.field_type != f2.field_type {
          diffs.push({
            field_name: f2.name,
            kind: TypeChanged(f1.field_type, f2.field_type),
            impact: Breaking,
            description: "Field '" + f2.name + "' type changed from " + f1.field_type.to_string() + " to " + f2.field_type.to_string(),
          })
        }

        // Check required change
        if f1.required != f2.required {
          let impact : ImpactLevel = if f2.required {
            Breaking // Changed to required
          } else {
            NonBreaking // Relaxed to optional
          }
          diffs.push({
            field_name: f2.name,
            kind: RequiredChanged(f1.required, f2.required),
            impact,
            description: "Field '" + f2.name + "' required constraint changed from " + f1.required.to_string() + " to " + f2.required.to_string(),
          })
        }
      }
    }
  }

  // Check removed fields from v1
  for i = 0; i < v1.fields.length(); i = i + 1 {
    let f1 = v1.fields[i]
    match find_field_by_name(v2.fields, f1.name) {
      None => {
        diffs.push({
          field_name: f1.name,
          kind: FieldRemoved(f1),
          impact: Breaking,
          description: "Field '" + f1.name + "' removed in v2",
        })
      }
      Some(_) => ()
    }
  }

  diffs
}
