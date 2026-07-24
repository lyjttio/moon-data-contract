test "generators: export contract schema to SQL, Protobuf, TS" {
  let header = @types.SchemaHeader::new("order_schema", "OrderPayload", "1.0.0", space_name="orders")
  let f1 = @types.Field::new(1, "id", @types.DataType::Primitive(@types.PrimitiveKind::PString), primary_key=true)
  let f2 = @types.Field::new(2, "amount", @types.DataType::Primitive(@types.PrimitiveKind::PDouble), required=true, description="Order total amount")
  let f3 = @types.Field::new(3, "note", @types.DataType::Primitive(@types.PrimitiveKind::PString), required=false)

  let schema = @types.ContractSchema::new(header, [f1, f2, f3])

  let sql = export_to_sql_ddl(schema, dialect="mysql")
  assert_true(sql.contains("CREATE TABLE IF NOT EXISTS `OrderPayload`"))
  assert_true(sql.contains("`id` VARCHAR(255) NOT NULL"))

  let proto = export_to_protobuf(schema)
  assert_true(proto.contains("syntax = \"proto3\";"))
  assert_true(proto.contains("package orders;"))
  assert_true(proto.contains("double amount = 2;"))

  let ts = export_to_typescript(schema)
  assert_true(ts.contains("export interface OrderPayload"))
  assert_true(ts.contains("note?: string;"))
}
