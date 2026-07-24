test "cli: argument parsing" {
  let c1 = parse_cli_args(["validate", "schema.json", "payload.json"])
  assert_eq(c1, CmdValidate("schema.json", "payload.json"))

  let c2 = parse_cli_args(["export", "user.json", "ts"])
  assert_eq(c2, CmdExport("user.json", "ts"))

  let c3 = parse_cli_args(["version"])
  assert_eq(c3, CmdVersion)
}

test "cli: command runner" {
  let header = @types.SchemaHeader::new("test_schema", "User", "1.0.0")
  let f1 = @types.Field::new(1, "id", @types.DataType::Primitive(@types.PrimitiveKind::PInt))
  let schema = @types.ContractSchema::new(header, [f1])

  let res_ts = run_cli_command(CmdExport("s.json", "ts"), schema)
  assert_true(res_ts.contains("export interface User"))
}
