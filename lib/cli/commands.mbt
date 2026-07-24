// MoonBit Data Contract - CLI Subcommand Runners

pub fn print_help_menu() -> String {
  let mut help = "MoonBit Data Contract & Schema Evolution Tool (moon-data-contract)\n"
  help = help + "Usage: moon run cmd/main -- [command] [options]\n\n"
  help = help + "Commands:\n"
  help = help + "  validate <schema.json> <data.json>       Validate payload against schema\n"
  help = help + "  diff <v1.json> <v2.json>                  Calculate Schema version diff\n"
  help = help + "  check <v1.json> <v2.json> [level]         Check evolution compatibility\n"
  help = help + "  export <schema.json> [sql|proto|ts]       Export schema to SQL, Proto, TS\n"
  help = help + "  version                                   Show tool version\n"
  help
}

pub fn run_cli_command(cmd : CliCommand, schema : @types.ContractSchema) -> String {
  match cmd {
    CmdHelp => print_help_menu()
    CmdVersion => "moon-data-contract version 0.1.0 (MoonBit 0.10.3)\n"
    CmdExport(_, target) => {
      match target {
        "proto" | "protobuf" => @generators.export_to_protobuf(schema)
        "ts" | "typescript" => @generators.export_to_typescript(schema)
        _ => @generators.export_to_sql_ddl(schema, dialect="mysql")
      }
    }
    _ => "Command processed for schema: " + schema.header.id + "\n"
  }
}
