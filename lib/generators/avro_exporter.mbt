// MoonBit Data Contract - Apache Avro Schema JSON Exporter (.avsc)

///|
pub fn map_type_to_avro(data_type : @types.DataType) -> String {
  match data_type {
    Primitive(PBool) => "\"boolean\""
    Primitive(PInt) => "\"int\""
    Primitive(PInt64) => "\"long\""
    Primitive(PDouble) => "\"double\""
    Primitive(PString) => "\"string\""
    Primitive(PBytes) => "\"bytes\""
    Primitive(PTimestamp) =>
      "{\"type\": \"long\", \"logicalType\": \"timestamp-millis\"}"
    EnumDef(_, vals) => {
      let mut res = "{\"type\": \"enum\", \"name\": \"EnumVal\", \"symbols\": ["
      for i = 0; i < vals.length(); i = i + 1 {
        if i > 0 {
          res = res + ", "
        }
        res = res + "\"" + vals[i] + "\""
      }
      res + "]}"
    }
    ArrayDef(inner) =>
      "{\"type\": \"array\", \"items\": " + map_type_to_avro(inner) + "}"
    MapDef(_, v) =>
      "{\"type\": \"map\", \"values\": " + map_type_to_avro(v) + "}"
    OptionalDef(inner) => "[\"null\", " + map_type_to_avro(inner) + "]"
    StructDef(name, _) => "\"" + name + "\""
    UnionDef(_) => "\"string\""
  }
}

///|
pub fn export_to_avro_schema(schema : @types.ContractSchema) -> String {
  let mut avro = "{\n"
  avro = avro + "  \"type\": \"record\",\n"
  avro = avro + "  \"name\": \"" + schema.header.name + "\",\n"
  avro = avro + "  \"namespace\": \"" + schema.header.id + "\",\n"
  avro = avro + "  \"fields\": [\n"

  for i = 0; i < schema.fields.length(); i = i + 1 {
    let f = schema.fields[i]
    let avro_t = map_type_to_avro(f.field_type)
    avro = avro + "    {\n"
    avro = avro + "      \"name\": \"" + f.name + "\",\n"
    avro = avro + "      \"type\": " + avro_t
    if f.description.length() > 0 {
      avro = avro + ",\n      \"doc\": \"" + f.description + "\""
    }
    avro = avro + "\n    }"
    if i < schema.fields.length() - 1 {
      avro = avro + ","
    }
    avro = avro + "\n"
  }

  avro = avro + "  ]\n}\n"
  avro
}
