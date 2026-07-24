// MoonBit Data Contract & Schema Evolution Tool - Core Types

pub(all) enum PrimitiveType {
  TBool
  TInt
  TDouble
  TString
} derive(Debug, Eq)

pub(all) enum DataType {
  Primitive(PrimitiveType)
  EnumDef(Array[String])
  ArrayDef(DataType)
  OptionalDef(DataType)
  StructDef(Array[Field])
} derive(Debug, Eq)

pub(all) struct FieldConstraint {
  min_value : Double?
  max_value : Double?
  pattern : String?
  allowed_values : Array[String]?
} derive(Debug, Eq)

pub fn FieldConstraint::default() -> FieldConstraint {
  {
    min_value: None,
    max_value: None,
    pattern: None,
    allowed_values: None,
  }
}

pub(all) struct Field {
  name : String
  field_type : DataType
  required : Bool
  primary_key : Bool
  description : String
  constraint : FieldConstraint
} derive(Debug, Eq)

pub fn Field::new(
  name : String,
  field_type : DataType,
  required~ : Bool = true,
  primary_key~ : Bool = false,
  description~ : String = "",
  constraint~ : FieldConstraint = FieldConstraint::default()
) -> Field {
  {
    name,
    field_type,
    required,
    primary_key,
    description,
    constraint,
  }
}

pub(all) struct Schema {
  id : String
  name : String
  version : String
  owner : String
  fields : Array[Field]
} derive(Debug, Eq)

pub fn Schema::new(
  id : String,
  name : String,
  version : String,
  owner : String,
  fields : Array[Field]
) -> Schema {
  { id, name, version, owner, fields }
}

pub(all) enum CompatibilityLevel {
  NoneLevel
  Backward
  Forward
  Full
} derive(Debug, Eq)

pub fn CompatibilityLevel::from_string(s : String) -> CompatibilityLevel {
  match s {
    "BACKWARD" | "backward" => Backward
    "FORWARD" | "forward" => Forward
    "FULL" | "full" => Full
    _ => NoneLevel
  }
}

pub fn CompatibilityLevel::to_string(self : CompatibilityLevel) -> String {
  match self {
    Backward => "BACKWARD"
    Forward => "FORWARD"
    Full => "FULL"
    NoneLevel => "NONE"
  }
}

pub(all) enum ImpactLevel {
  NonBreaking
  Breaking
} derive(Debug, Eq)

pub(all) enum ChangeKind {
  FieldAdded(Field)
  FieldRemoved(Field)
  TypeChanged(DataType, DataType)
  RequiredChanged(Bool, Bool)
  ConstraintChanged(String, String)
} derive(Debug, Eq)

pub(all) struct DiffEntry {
  field_name : String
  kind : ChangeKind
  impact : ImpactLevel
  description : String
} derive(Debug, Eq)

pub(all) struct EvolutionReport {
  schema_id : String
  v1_version : String
  v2_version : String
  is_compatible : Bool
  level : CompatibilityLevel
  diffs : Array[DiffEntry]
  breaking_count : Int
  non_breaking_count : Int
} derive(Debug, Eq)

pub(all) struct ValidationError {
  field : String
  message : String
  code : String
} derive(Debug, Eq)

pub(all) struct ValidationResult {
  is_valid : Bool
  errors : Array[ValidationError]
} derive(Debug, Eq)

pub fn ValidationResult::ok() -> ValidationResult {
  { is_valid: true, errors: [] }
}

pub fn ValidationResult::fail(errors : Array[ValidationError]) -> ValidationResult {
  { is_valid: false, errors }
}
