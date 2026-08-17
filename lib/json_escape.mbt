// Small deterministic escaping helpers for machine-readable reports.

///|
pub fn json_escape(value : String) -> String {
  let mut escaped = ""
  for i = 0; i < value.length(); i = i + 1 {
    match value[i] {
      '\\' => escaped = escaped + "\\\\"
      '"' => escaped = escaped + "\\\""
      '\n' => escaped = escaped + "\\n"
      '\r' => escaped = escaped + "\\r"
      '\t' => escaped = escaped + "\\t"
      ch => escaped = escaped + String::from_array([ch.unsafe_to_char()])
    }
  }
  escaped
}

///|
fn xml_escape(value : String) -> String {
  let mut escaped = ""
  for i = 0; i < value.length(); i = i + 1 {
    match value[i] {
      '&' => escaped = escaped + "&amp;"
      '<' => escaped = escaped + "&lt;"
      '>' => escaped = escaped + "&gt;"
      '"' => escaped = escaped + "&quot;"
      '\'' => escaped = escaped + "&apos;"
      ch => escaped = escaped + String::from_array([ch.unsafe_to_char()])
    }
  }
  escaped
}
