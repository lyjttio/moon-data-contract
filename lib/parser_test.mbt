///|
test "parser: data type to string and parsing" {
  let t_int = DataType::Primitive(PrimitiveType::TInt)
  let t_opt = DataType::OptionalDef(t_int)
  let t_arr = DataType::ArrayDef(DataType::Primitive(PrimitiveType::TString))

  assert_eq(t_int.to_string(), "int")
  assert_eq(t_opt.to_string(), "optional<int>")
  assert_eq(t_arr.to_string(), "array<string>")

  assert_eq(DataType::from_string("int"), t_int)
  assert_eq(DataType::from_string("optional<int>"), t_opt)
  assert_eq(DataType::from_string("array<string>"), t_arr)
}

///|
test "parser: schema to json string" {
  let f1 = Field::new(
    "id",
    DataType::Primitive(PrimitiveType::TInt),
    primary_key=true,
    description="User ID",
  )
  let schema = Schema::new("user_schema", "User", "1.0.0", "data_team", [f1])
  let json_str = schema.to_json_string()

  assert_true(json_str.contains("\"id\": \"user_schema\""))
  assert_true(json_str.contains("\"name\": \"User\""))
  assert_true(json_str.contains("\"type\": \"int\""))
}
