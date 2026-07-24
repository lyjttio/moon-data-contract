// MoonBit Data Contract - Mock Payload Data Generator

///|
pub fn generate_mock_value(
  data_type : @types.DataType,
  field_name : String,
) -> String {
  match data_type {
    Primitive(PBool) => "true"
    Primitive(PInt) | Primitive(PInt64) => "1001"
    Primitive(PDouble) => "99.9"
    Primitive(PString) => "\"" + field_name + "_mock_val\""
    Primitive(PBytes) => "\"aW5wdXQ=\""
    Primitive(PTimestamp) => "\"2026-07-24T12:00:00Z\""
    EnumDef(_, vals) =>
      if vals.length() > 0 {
        "\"" + vals[0] + "\""
      } else {
        "\"DEFAULT\""
      }
    ArrayDef(inner) => "[" + generate_mock_value(inner, field_name) + "]"
    MapDef(_, _) => "{}"
    OptionalDef(inner) => generate_mock_value(inner, field_name)
    StructDef(_, _) => "{}"
    UnionDef(_) => "\"union_val\""
  }
}

///|
pub fn generate_mock_payload_json(schema : @types.ContractSchema) -> String {
  let mut json_str = "{\n"
  for i = 0; i < schema.fields.length(); i = i + 1 {
    let f = schema.fields[i]
    let val_str = generate_mock_value(f.field_type, f.name)
    json_str = json_str + "  \"" + f.name + "\": " + val_str
    if i < schema.fields.length() - 1 {
      json_str = json_str + ",\n"
    } else {
      json_str = json_str + "\n"
    }
  }
  json_str = json_str + "}\n"
  json_str
}
