// MoonBit Data Contract & Schema Evolution Tool - Schema JSON Parser & Serializer

pub fn DataType::to_string(self : DataType) -> String {
  match self {
    Primitive(TBool) => "bool"
    Primitive(TInt) => "int"
    Primitive(TDouble) => "double"
    Primitive(TString) => "string"
    EnumDef(vals) => {
      let mut res = "enum("
      for i = 0; i < vals.length(); i = i + 1 {
        if i > 0 {
          res = res + ","
        }
        res = res + vals[i]
      }
      res + ")"
    }
    ArrayDef(inner) => "array<" + inner.to_string() + ">"
    OptionalDef(inner) => "optional<" + inner.to_string() + ">"
    StructDef(_) => "struct"
  }
}

pub fn DataType::from_string(s : String) -> DataType {
  match s {
    "bool" | "boolean" => Primitive(TBool)
    "int" | "integer" => Primitive(TInt)
    "double" | "float" | "number" => Primitive(TDouble)
    "string" | "text" => Primitive(TString)
    _ => {
      if s.has_prefix("optional<") && s.has_suffix(">") {
        let inner_str = s[9:s.length() - 1].to_owned()
        OptionalDef(DataType::from_string(inner_str))
      } else if s.has_prefix("array<") && s.has_suffix(">") {
        let inner_str = s[6:s.length() - 1].to_owned()
        ArrayDef(DataType::from_string(inner_str))
      } else {
        Primitive(TString)
      }
    }
  }
}

pub fn Schema::to_json_string(self : Schema) -> String {
  let mut buf = "{\n"
  buf = buf + "  \"id\": \"" + self.id + "\",\n"
  buf = buf + "  \"name\": \"" + self.name + "\",\n"
  buf = buf + "  \"version\": \"" + self.version + "\",\n"
  buf = buf + "  \"owner\": \"" + self.owner + "\",\n"
  buf = buf + "  \"fields\": [\n"

  for i = 0; i < self.fields.length(); i = i + 1 {
    let f = self.fields[i]
    buf = buf + "    {\n"
    buf = buf + "      \"name\": \"" + f.name + "\",\n"
    buf = buf + "      \"type\": \"" + f.field_type.to_string() + "\",\n"
    buf = buf + "      \"required\": " + f.required.to_string() + ",\n"
    buf = buf + "      \"primary_key\": " + f.primary_key.to_string() + ",\n"
    buf = buf + "      \"description\": \"" + f.description + "\"\n"
    buf = buf + "    }"
    if i < self.fields.length() - 1 {
      buf = buf + ","
    }
    buf = buf + "\n"
  }

  buf = buf + "  ]\n}"
  buf
}
