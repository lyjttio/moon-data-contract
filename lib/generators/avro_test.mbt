///|
test "generators: export to avro schema" {
  let header = @types.SchemaHeader::new("payment_avro", "PaymentEvent", "1.0.0")
  let f1 = @types.Field::new(
    1,
    "id",
    @types.DataType::Primitive(@types.PrimitiveKind::PString),
  )
  let f2 = @types.Field::new(
    2,
    "amount",
    @types.DataType::Primitive(@types.PrimitiveKind::PDouble),
    description="Payment total",
  )
  let schema = @types.ContractSchema::new(header, [f1, f2])

  let avro = export_to_avro_schema(schema)
  assert_true(avro.contains("\"type\": \"record\""))
  assert_true(avro.contains("\"name\": \"PaymentEvent\""))
  assert_true(avro.contains("\"doc\": \"Payment total\""))
}
