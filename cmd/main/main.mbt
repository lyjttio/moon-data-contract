// MoonBit Data Contract CLI executable.

///|
fn main {
  let args = @env.args()
  let user_args = if args.length() > 0 { args[1:].to_owned() } else { [] }
  println(@cli.execute_cli_args(user_args))
}
