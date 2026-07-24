///|
test "generators: export to graphql sdl" {
  let header = @types.SchemaHeader::new(
    "gql_schema", "CustomerProfile", "1.0.0",
  )
  let f1 = @types.Field::new(
    1,
    "id",
    @types.DataType::Primitive(@types.PrimitiveKind::PString),
    required=true,
  )
  let f2 = @types.Field::new(
    2,
    "age",
    @types.DataType::Primitive(@types.PrimitiveKind::PInt),
    required=false,
    description="User age",
  )
  let schema = @types.ContractSchema::new(header, [f1, f2])

  let sdl = export_to_graphql_sdl(schema)
  assert_true(sdl.contains("type CustomerProfile"))
  assert_true(sdl.contains("id: String!"))
  assert_true(sdl.contains("age: Int"))
}
