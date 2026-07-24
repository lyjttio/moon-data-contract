///|
test "generators: mock payload generation" {
  let header = @types.SchemaHeader::new("mock_sch", "Payment", "1.0.0")
  let f1 = @types.Field::new(
    1,
    "tx_id",
    @types.DataType::Primitive(@types.PrimitiveKind::PString),
  )
  let f2 = @types.Field::new(
    2,
    "amount",
    @types.DataType::Primitive(@types.PrimitiveKind::PDouble),
  )

  let schema = @types.ContractSchema::new(header, [f1, f2])
  let json_str = generate_mock_payload_json(schema)

  assert_true(json_str.contains("\"tx_id\": \"tx_id_mock_val\""))
  assert_true(json_str.contains("\"amount\": 99.9"))
}
