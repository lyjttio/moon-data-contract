// MoonBit Data Contract - CLI Argument Parser

///|
pub(all) enum CliCommand {
  CmdValidate(String, String)
  CmdDiff(String, String)
  CmdCheck(String, String, String)
  CmdExport(String, String)
  CmdBenchmark
  CmdAudit
  CmdGovern
  CmdSnapshot
  CmdPlan
  CmdPolicy
  CmdHelp
  CmdVersion
} derive(Debug, Eq)

///|
pub fn parse_cli_args(args : Array[String]) -> CliCommand {
  if args.length() == 0 {
    return CmdHelp
  }
  let sub = args[0]
  match sub {
    "validate" =>
      if args.length() >= 3 {
        CmdValidate(args[1], args[2])
      } else {
        CmdHelp
      }
    "diff" =>
      if args.length() >= 3 {
        CmdDiff(args[1], args[2])
      } else {
        CmdHelp
      }
    "check" => {
      let level = if args.length() >= 4 { args[3] } else { "BACKWARD" }
      if args.length() >= 3 {
        CmdCheck(args[1], args[2], level)
      } else {
        CmdHelp
      }
    }
    "export" => {
      let target = if args.length() >= 3 { args[2] } else { "sql" }
      if args.length() >= 2 {
        CmdExport(args[1], target)
      } else {
        CmdHelp
      }
    }
    "benchmark" => CmdBenchmark
    "audit" => CmdAudit
    "govern" => CmdGovern
    "snapshot" => CmdSnapshot
    "plan" => CmdPlan
    "policy" => CmdPolicy
    "version" | "-v" | "--version" => CmdVersion
    _ => CmdHelp
  }
}
