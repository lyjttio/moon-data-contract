// Reusable schema shape profile for governance reports and CI thresholds.

///|
pub(all) struct SchemaProfile {
  total_fields : Int
  required_fields : Int
  optional_fields : Int
  bool_fields : Int
  int_fields : Int
  double_fields : Int
  string_fields : Int
  composite_fields : Int
  max_depth : Int
} derive(Debug, Eq)

///|
fn empty_schema_profile() -> SchemaProfile {
  {
    total_fields: 0,
    required_fields: 0,
    optional_fields: 0,
    bool_fields: 0,
    int_fields: 0,
    double_fields: 0,
    string_fields: 0,
    composite_fields: 0,
    max_depth: 0,
  }
}

///|
fn profile_add(left : SchemaProfile, right : SchemaProfile) -> SchemaProfile {
  {
    total_fields: left.total_fields + right.total_fields,
    required_fields: left.required_fields + right.required_fields,
    optional_fields: left.optional_fields + right.optional_fields,
    bool_fields: left.bool_fields + right.bool_fields,
    int_fields: left.int_fields + right.int_fields,
    double_fields: left.double_fields + right.double_fields,
    string_fields: left.string_fields + right.string_fields,
    composite_fields: left.composite_fields + right.composite_fields,
    max_depth: if left.max_depth > right.max_depth {
      left.max_depth
    } else {
      right.max_depth
    },
  }
}

///|
fn profile_type(data_type : DataType, depth : Int) -> SchemaProfile {
  match data_type {
    DataType::Primitive(PrimitiveType::TBool) => {
      let result = empty_schema_profile()
      { ..result, bool_fields: 1, max_depth: depth }
    }
    DataType::Primitive(PrimitiveType::TInt) => {
      let result = empty_schema_profile()
      { ..result, int_fields: 1, max_depth: depth }
    }
    DataType::Primitive(PrimitiveType::TDouble) => {
      let result = empty_schema_profile()
      { ..result, double_fields: 1, max_depth: depth }
    }
    DataType::Primitive(PrimitiveType::TString) => {
      let result = empty_schema_profile()
      { ..result, string_fields: 1, max_depth: depth }
    }
    DataType::StructDef(fields) => {
      let nested = profile_fields(fields, depth + 1)
      { ..nested, composite_fields: nested.composite_fields + 1 }
    }
    DataType::ArrayDef(inner) => {
      let nested = profile_type(inner, depth)
      { ..nested, composite_fields: nested.composite_fields + 1 }
    }
    DataType::OptionalDef(inner) => {
      let nested = profile_type(inner, depth)
      { ..nested, composite_fields: nested.composite_fields + 1 }
    }
    DataType::EnumDef(_) => {
      let result = empty_schema_profile()
      { ..result, composite_fields: 1, string_fields: 1, max_depth: depth }
    }
  }
}

///|
fn profile_fields(fields : Array[Field], depth : Int) -> SchemaProfile {
  let mut profile = empty_schema_profile()
  for field in fields {
    let type_profile = profile_type(field.field_type, depth)
    let field_profile = {
      total_fields: 1 + type_profile.total_fields,
      required_fields: (if field.required { 1 } else { 0 }) +
      type_profile.required_fields,
      optional_fields: (if field.required { 0 } else { 1 }) +
      type_profile.optional_fields,
      bool_fields: type_profile.bool_fields,
      int_fields: type_profile.int_fields,
      double_fields: type_profile.double_fields,
      string_fields: type_profile.string_fields,
      composite_fields: type_profile.composite_fields,
      max_depth: if type_profile.max_depth > depth {
        type_profile.max_depth
      } else {
        depth
      },
    }
    profile = profile_add(profile, field_profile)
  }
  profile
}

///|
pub fn profile_schema(schema : Schema) -> SchemaProfile {
  profile_fields(schema.fields, 1)
}

///|
pub fn SchemaProfile::required_ratio(self : SchemaProfile) -> Double {
  if self.total_fields == 0 {
    0.0
  } else {
    self.required_fields.to_double() / self.total_fields.to_double()
  }
}

///|
pub fn SchemaProfile::primitive_fields(self : SchemaProfile) -> Int {
  self.bool_fields + self.int_fields + self.double_fields + self.string_fields
}

///|
pub fn SchemaProfile::complexity_score(self : SchemaProfile) -> Int {
  self.total_fields +
  self.composite_fields * 2 +
  self.max_depth +
  self.optional_fields
}

///|
pub fn SchemaProfile::to_json(self : SchemaProfile) -> String {
  "{\"total_fields\":" +
  self.total_fields.to_string() +
  ",\"required_fields\":" +
  self.required_fields.to_string() +
  ",\"optional_fields\":" +
  self.optional_fields.to_string() +
  ",\"bool_fields\":" +
  self.bool_fields.to_string() +
  ",\"int_fields\":" +
  self.int_fields.to_string() +
  ",\"double_fields\":" +
  self.double_fields.to_string() +
  ",\"string_fields\":" +
  self.string_fields.to_string() +
  ",\"composite_fields\":" +
  self.composite_fields.to_string() +
  ",\"max_depth\":" +
  self.max_depth.to_string() +
  "}"
}

///|
pub fn SchemaProfile::to_markdown(self : SchemaProfile) -> String {
  let mut output = "## Schema Profile\n\n"
  output = output + "- Total fields: " + self.total_fields.to_string() + "\n"
  output = output +
    "- Required fields: " +
    self.required_fields.to_string() +
    "\n"
  output = output +
    "- Optional fields: " +
    self.optional_fields.to_string() +
    "\n"
  output = output +
    "- Composite fields: " +
    self.composite_fields.to_string() +
    "\n"
  output = output + "- Maximum depth: " + self.max_depth.to_string() + "\n"
  output = output +
    "- Required ratio: " +
    self.required_ratio().to_string() +
    "\n"
  output = output +
    "- Primitive distribution: bool=" +
    self.bool_fields.to_string()
  output = output + ", int=" + self.int_fields.to_string()
  output = output + ", double=" + self.double_fields.to_string()
  output + ", string=" + self.string_fields.to_string() + "\n"
}
