///|
test "generators: export to parquet schema" {
  let header = @types.SchemaHeader::new("pq_schema", "AnalyticsEvent", "1.0.0")
  let f1 = @types.Field::new(
    1,
    "event_id",
    @types.DataType::Primitive(@types.PrimitiveKind::PString),
    required=true,
  )
  let f2 = @types.Field::new(
    2,
    "ts",
    @types.DataType::Primitive(@types.PrimitiveKind::PTimestamp),
    required=true,
  )
  let schema = @types.ContractSchema::new(header, [f1, f2])

  let pq = export_to_parquet_schema(schema)
  assert_true(pq.contains("message AnalyticsEvent"))
  assert_true(pq.contains("required BYTE_ARRAY (UTF8) event_id;"))
}
