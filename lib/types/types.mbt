// MoonBit Data Contract - Advanced Type System Definitions

pub(all) enum PrimitiveKind {
  PBool
  PInt
  PInt64
  PDouble
  PString
  PBytes
  PTimestamp
} derive(Debug, Eq)

pub fn PrimitiveKind::to_string(self : PrimitiveKind) -> String {
  match self {
    PBool => "bool"
    PInt => "int"
    PInt64 => "int64"
    PDouble => "double"
    PString => "string"
    PBytes => "bytes"
    PTimestamp => "timestamp"
  }
}

pub fn PrimitiveKind::from_string(s : String) -> PrimitiveKind {
  match s {
    "bool" | "boolean" => PBool
    "int" | "integer" | "int32" => PInt
    "int64" | "long" => PInt64
    "double" | "float" | "number" => PDouble
    "string" | "text" => PString
    "bytes" | "binary" => PBytes
    "timestamp" | "datetime" | "date" => PTimestamp
    _ => PString
  }
}

pub(all) enum DataType {
  Primitive(PrimitiveKind)
  EnumDef(String, Array[String])
  ArrayDef(DataType)
  MapDef(DataType, DataType)
  OptionalDef(DataType)
  StructDef(String, Array[Field])
  UnionDef(Array[DataType])
} derive(Debug, Eq)

pub fn DataType::to_string(self : DataType) -> String {
  match self {
    Primitive(kind) => kind.to_string()
    EnumDef(name, vals) => {
      let mut res = "enum " + name + " {"
      for i = 0; i < vals.length(); i = i + 1 {
        if i > 0 {
          res = res + ", "
        }
        res = res + vals[i]
      }
      res + "}"
    }
    ArrayDef(inner) => "array<" + inner.to_string() + ">"
    MapDef(k, v) => "map<" + k.to_string() + ", " + v.to_string() + ">"
    OptionalDef(inner) => "optional<" + inner.to_string() + ">"
    StructDef(name, _) => "struct " + name
    UnionDef(types) => {
      let mut res = "union<"
      for i = 0; i < types.length(); i = i + 1 {
        if i > 0 {
          res = res + " | "
        }
        res = res + types[i].to_string()
      }
      res + ">"
    }
  }
}

pub(all) struct NumericRange {
  min_value : Double?
  max_value : Double?
  exclusive_min : Bool
  exclusive_max : Bool
  multiple_of : Double?
} derive(Debug, Eq)

pub fn NumericRange::default() -> NumericRange {
  {
    min_value: None,
    max_value: None,
    exclusive_min: false,
    exclusive_max: false,
    multiple_of: None,
  }
}

pub(all) struct StringRule {
  min_length : Int?
  max_length : Int?
  pattern : String?
  format_kind : String?
} derive(Debug, Eq)

pub fn StringRule::default() -> StringRule {
  {
    min_length: None,
    max_length: None,
    pattern: None,
    format_kind: None,
  }
}

pub(all) struct FieldConstraint {
  numeric : NumericRange
  string_rule : StringRule
  allowed_enums : Array[String]?
  default_value_raw : String?
} derive(Debug, Eq)

pub fn FieldConstraint::default() -> FieldConstraint {
  {
    numeric: NumericRange::default(),
    string_rule: StringRule::default(),
    allowed_enums: None,
    default_value_raw: None,
  }
}

pub(all) struct Field {
  id : Int
  name : String
  field_type : DataType
  required : Bool
  primary_key : Bool
  deprecated : Bool
  description : String
  constraint : FieldConstraint
} derive(Debug, Eq)

pub fn Field::new(
  id : Int,
  name : String,
  field_type : DataType,
  required~ : Bool = true,
  primary_key~ : Bool = false,
  deprecated~ : Bool = false,
  description~ : String = "",
  constraint~ : FieldConstraint = FieldConstraint::default()
) -> Field {
  {
    id,
    name,
    field_type,
    required,
    primary_key,
    deprecated,
    description,
    constraint,
  }
}

pub(all) struct SchemaHeader {
  id : String
  name : String
  space_name : String
  version : String
  owner : String
  doc : String
  tags : Map[String, String]
} derive(Debug, Eq)

pub fn SchemaHeader::new(
  id : String,
  name : String,
  version : String,
  space_name~ : String = "default",
  owner~ : String = "data_eng",
  doc~ : String = "",
  tags~ : Map[String, String] = Map([])
) -> SchemaHeader {
  { id, name, space_name, version, owner, doc, tags }
}

pub(all) struct ContractSchema {
  header : SchemaHeader
  fields : Array[Field]
} derive(Debug, Eq)

pub fn ContractSchema::new(
  header : SchemaHeader,
  fields : Array[Field]
) -> ContractSchema {
  { header, fields }
}
