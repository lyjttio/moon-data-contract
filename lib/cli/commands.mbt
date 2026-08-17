// MoonBit Data Contract - CLI Subcommand Runners

///|
pub fn print_help_menu() -> String {
  let mut help = "MoonBit Data Contract & Schema Evolution Tool (moon-data-contract)\n"
  help = help + "Usage: moon run cmd/main -- [command] [options]\n\n"
  help = help + "Commands:\n"
  help = help +
    "  validate <schema.json> <data.json>       Preview validation request\n"
  help = help +
    "  diff <v1.json> <v2.json>                  Preview Schema version diff\n"
  help = help +
    "  check <v1.json> <v2.json> [level]         Preview compatibility check\n"
  help = help +
    "  export <schema.json> [sql|proto|ts]       Export the in-memory demo schema\n"
  help = help +
    "  benchmark                                Run deterministic contract benchmark\n"
  help = help +
    "  audit                                     Run contract acceptance audit\n"
  help = help +
    "  govern                                    Render the release governance report\n"
  help = help +
    "  snapshot                                  Inspect the deterministic snapshot chain\n"
  help = help +
    "  plan                                      Render the next migration plan\n"
  help = help +
    "  policy                                    Evaluate the strict policy for the next transition\n"
  help = help +
    "  version                                   Show tool version\n"
  help +
  "\nPortable CLI note: JSON file contents are not decoded yet; use the library APIs for loaded schemas and payloads.\n"
}

///|
pub fn run_cli_command(
  cmd : CliCommand,
  schema : @types.ContractSchema,
) -> String {
  match cmd {
    CmdHelp => print_help_menu()
    CmdVersion =>
      "moon-data-contract version 0.2.0 (MoonBit stable toolchain)\n"
    CmdBenchmark => @lib.run_standard_benchmark().to_markdown()
    CmdAudit => {
      let workload = @lib.standard_benchmark_workloads()[0]
      @lib.audit_contract(
        workload.schema,
        workload.next_schema,
        workload.payload,
        @lib.CompatibilityLevel::Backward,
      ).to_markdown()
    }
    CmdGovern =>
      @lib.govern_subject(
        @lib.benchmark_governance_store(),
        "orders",
        @lib.GovernancePolicy::strict(),
        @lib.CompatibilityLevel::Backward,
      ).to_markdown()
    CmdSnapshot => {
      let report = @lib.analyze_snapshot_chain(
        @lib.benchmark_governance_snapshots(),
      )
      "Snapshot chain\n" +
      "- Subject: orders\n" +
      "- Versions: " +
      report.ordered_versions.length().to_string() +
      "\n" +
      "- Issues: " +
      report.issues.length().to_string() +
      "\n"
    }
    CmdPlan => {
      let snapshots = @lib.benchmark_governance_snapshots()
      let plan = @lib.plan_schema_migration(
        snapshots[0].schema,
        snapshots[1].schema,
      )
      "Migration plan\n" +
      "- Base: " +
      plan.base_version +
      "\n" +
      "- Target: " +
      plan.target_version +
      "\n" +
      "- Actions: " +
      plan.actions.length().to_string() +
      "\n"
    }
    CmdPolicy => {
      let snapshots = @lib.benchmark_governance_snapshots()
      let findings = @lib.evaluate_policy(
        @lib.GovernancePolicy::strict(),
        snapshots[0].schema,
        snapshots[1].schema,
        @lib.CompatibilityLevel::Backward,
      )
      "Policy evaluation\n" +
      "- Findings: " +
      findings.length().to_string() +
      "\n"
    }
    CmdValidate(schema_path, payload_path) =>
      "Validation preview\n" +
      "- Schema artifact: " +
      schema_path +
      "\n" +
      "- Payload artifact: " +
      payload_path +
      "\n" +
      "- Status: file decoding is not enabled in the portable CLI; use validate_schema_payload with decoded data.\n"
    CmdDiff(v1_path, v2_path) =>
      "Diff preview\n" +
      "- Version 1 artifact: " +
      v1_path +
      "\n" +
      "- Version 2 artifact: " +
      v2_path +
      "\n" +
      "- Status: file decoding is not enabled in the portable CLI; use diff_schemas with ContractSchema values.\n"
    CmdCheck(v1_path, v2_path, level) =>
      "Compatibility preview\n" +
      "- Version 1 artifact: " +
      v1_path +
      "\n" +
      "- Version 2 artifact: " +
      v2_path +
      "\n" +
      "- Requested level: " +
      level +
      "\n" +
      "- Status: file decoding is not enabled in the portable CLI; use check_compatibility with ContractSchema values.\n"
    CmdExport(source_path, target) => {
      let rendered = match target {
        "proto" | "protobuf" => @generators.export_to_protobuf(schema)
        "ts" | "typescript" => @generators.export_to_typescript(schema)
        _ => @generators.export_to_sql_ddl(schema, dialect="mysql")
      }
      "Export preview for artifact " + source_path + "\n" + rendered
    }
  }
}

///|
fn cli_demo_schema() -> @types.ContractSchema {
  let header = @types.SchemaHeader::new(
    "demo_contract", "DemoContract", "1.0.0",
  )
  let id = @types.Field::new(
    1,
    "id",
    @types.DataType::Primitive(@types.PrimitiveKind::PInt),
  )
  let name = @types.Field::new(
    2,
    "name",
    @types.DataType::Primitive(@types.PrimitiveKind::PString),
  )
  @types.ContractSchema::new(header, [id, name])
}

///|
pub fn execute_cli_args(args : Array[String]) -> String {
  run_cli_command(parse_cli_args(args), cli_demo_schema())
}
