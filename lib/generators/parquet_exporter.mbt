// MoonBit Data Contract - Apache Parquet Schema Exporter

///|
pub fn map_type_to_parquet(data_type : @types.DataType) -> String {
  match data_type {
    Primitive(PBool) => "BOOLEAN"
    Primitive(PInt) => "INT32"
    Primitive(PInt64) => "INT64"
    Primitive(PDouble) => "DOUBLE"
    Primitive(PString) => "BYTE_ARRAY (UTF8)"
    Primitive(PBytes) => "BYTE_ARRAY"
    Primitive(PTimestamp) => "INT64 (TIMESTAMP_MILLIS)"
    EnumDef(_, _) => "BYTE_ARRAY (UTF8)"
    ArrayDef(inner) => "LIST<" + map_type_to_parquet(inner) + ">"
    MapDef(_, v) => "MAP<STRING, " + map_type_to_parquet(v) + ">"
    OptionalDef(inner) => map_type_to_parquet(inner)
    StructDef(name, _) => name
    UnionDef(_) => "BYTE_ARRAY (UTF8)"
  }
}

///|
pub fn export_to_parquet_schema(schema : @types.ContractSchema) -> String {
  let mut pq = "message " + schema.header.name + " {\n"
  for i = 0; i < schema.fields.length(); i = i + 1 {
    let f = schema.fields[i]
    let repetition = if f.required { "required" } else { "optional" }
    let pq_type = map_type_to_parquet(f.field_type)
    pq = pq + "  " + repetition + " " + pq_type + " " + f.name + ";\n"
  }
  pq = pq + "}\n"
  pq
}
