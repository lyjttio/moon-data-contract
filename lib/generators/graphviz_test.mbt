///|
test "generators: export to graphviz dot" {
  let header = @types.SchemaHeader::new("dot_schema", "Customer", "1.0.0")
  let f1 = @types.Field::new(
    1,
    "id",
    @types.DataType::Primitive(@types.PrimitiveKind::PString),
    primary_key=true,
  )
  let schema = @types.ContractSchema::new(header, [f1])

  let dot = export_to_graphviz_dot(schema)
  assert_true(dot.contains("digraph Customer"))
  assert_true(dot.contains("Customer</b> (v1.0.0)"))
}
