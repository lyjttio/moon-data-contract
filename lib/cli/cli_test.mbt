///|
test "cli: argument parsing" {
  let c1 = parse_cli_args(["validate", "schema.json", "payload.json"])
  assert_eq(c1, CmdValidate("schema.json", "payload.json"))

  let c2 = parse_cli_args(["export", "user.json", "ts"])
  assert_eq(c2, CmdExport("user.json", "ts"))

  let c3 = parse_cli_args(["version"])
  assert_eq(c3, CmdVersion)

  let c4 = parse_cli_args(["benchmark"])
  assert_eq(c4, CmdBenchmark)

  let c5 = parse_cli_args(["audit"])
  assert_eq(c5, CmdAudit)

  let c6 = parse_cli_args(["govern"])
  assert_eq(c6, CmdGovern)

  let c7 = parse_cli_args(["snapshot"])
  assert_eq(c7, CmdSnapshot)

  let c8 = parse_cli_args(["plan"])
  assert_eq(c8, CmdPlan)

  let c9 = parse_cli_args(["policy"])
  assert_eq(c9, CmdPolicy)
}

///|
test "cli: command runner" {
  let header = @types.SchemaHeader::new("test_schema", "User", "1.0.0")
  let f1 = @types.Field::new(
    1,
    "id",
    @types.DataType::Primitive(@types.PrimitiveKind::PInt),
  )
  let schema = @types.ContractSchema::new(header, [f1])

  let res_ts = run_cli_command(CmdExport("s.json", "ts"), schema)
  assert_true(res_ts.contains("Export preview for artifact s.json"))
  assert_true(res_ts.contains("export interface User"))

  let res_validate = run_cli_command(
    CmdValidate("schema.json", "payload.json"),
    schema,
  )
  assert_true(res_validate.contains("schema.json"))
  assert_true(res_validate.contains("file decoding is not enabled"))

  let res_benchmark = run_cli_command(CmdBenchmark, schema)
  assert_true(res_benchmark.contains("Contract Benchmark Report"))

  let res_audit = run_cli_command(CmdAudit, schema)
  assert_true(res_audit.contains("Contract Audit"))

  let res_govern = run_cli_command(CmdGovern, schema)
  assert_true(res_govern.contains("Contract Governance Report"))

  let res_snapshot = run_cli_command(CmdSnapshot, schema)
  assert_true(res_snapshot.contains("Snapshot chain"))

  let res_plan = run_cli_command(CmdPlan, schema)
  assert_true(res_plan.contains("Migration plan"))

  let res_policy = run_cli_command(CmdPolicy, schema)
  assert_true(res_policy.contains("Policy evaluation"))
}

///|
test "cli: execute user arguments through the public entrypoint" {
  let benchmark_output = execute_cli_args(["benchmark"])
  assert_true(benchmark_output.contains("Total operations"))
  let help_output = execute_cli_args([])
  assert_true(help_output.contains("Usage:"))
  assert_true(
    execute_cli_args(["govern"]).contains("Contract Governance Report"),
  )
}
