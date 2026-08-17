// Schema shape metrics used by audit reports and acceptance evidence.

///|
fn audit_type_metrics(data_type : DataType, depth : Int) -> AuditMetrics {
  match data_type {
    DataType::StructDef(fields) => audit_fields_metrics(fields, depth + 1)
    DataType::ArrayDef(inner) => audit_type_metrics(inner, depth)
    DataType::OptionalDef(inner) => audit_type_metrics(inner, depth)
    _ =>
      {
        top_level_fields: 0,
        total_fields: 0,
        max_depth: depth,
        constrained_fields: 0,
      }
  }
}

///|
fn audit_fields_metrics(fields : Array[Field], depth : Int) -> AuditMetrics {
  let mut total_fields = fields.length()
  let mut max_depth = depth
  let mut constrained_fields = 0
  for field in fields {
    if field.constraint.min_value is Some(_) ||
      field.constraint.max_value is Some(_) ||
      field.constraint.pattern is Some(_) ||
      field.constraint.allowed_values is Some(_) {
      constrained_fields += 1
    }
    let nested = audit_type_metrics(field.field_type, depth)
    total_fields += nested.total_fields
    if nested.max_depth > max_depth {
      max_depth = nested.max_depth
    }
    constrained_fields += nested.constrained_fields
  }
  {
    top_level_fields: fields.length(),
    total_fields,
    max_depth,
    constrained_fields,
  }
}

///|
pub fn analyze_schema(schema : Schema) -> AuditMetrics {
  audit_fields_metrics(schema.fields, 1)
}
