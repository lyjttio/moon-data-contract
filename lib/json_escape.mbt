// Deterministic JSON/XML escaping for machine-readable governance reports.

///|
fn hex_digit(value : Int) -> String {
  match value {
    0 => "0"
    1 => "1"
    2 => "2"
    3 => "3"
    4 => "4"
    5 => "5"
    6 => "6"
    7 => "7"
    8 => "8"
    9 => "9"
    10 => "a"
    11 => "b"
    12 => "c"
    13 => "d"
    14 => "e"
    _ => "f"
  }
}

///|
fn json_control_escape(code_point : Int) -> String {
  "\\u" +
  hex_digit((code_point >> 12) & 15) +
  hex_digit((code_point >> 8) & 15) +
  hex_digit((code_point >> 4) & 15) +
  hex_digit(code_point & 15)
}

///|
pub fn json_escape(value : String) -> String {
  let mut escaped = ""
  for ch in value.iter() {
    match ch {
      '\\' => escaped = escaped + "\\\\"
      '"' => escaped = escaped + "\\\""
      '\n' => escaped = escaped + "\\n"
      '\r' => escaped = escaped + "\\r"
      '\t' => escaped = escaped + "\\t"
      '\b' => escaped = escaped + "\\b"
      '\u{0C}' => escaped = escaped + "\\f"
      ch => {
        let code_point = ch.to_int()
        if code_point < 32 {
          escaped = escaped + json_control_escape(code_point)
        } else {
          escaped = escaped + String::from_array([ch])
        }
      }
    }
  }
  escaped
}

///|
fn xml_escape(value : String) -> String {
  let mut escaped = ""
  for ch in value.iter() {
    match ch {
      '&' => escaped = escaped + "&amp;"
      '<' => escaped = escaped + "&lt;"
      '>' => escaped = escaped + "&gt;"
      '"' => escaped = escaped + "&quot;"
      '\'' => escaped = escaped + "&apos;"
      '\t' | '\n' | '\r' => escaped = escaped + String::from_array([ch])
      ch =>
        if ch.to_int() < 32 {
          ()
        } else {
          escaped = escaped + String::from_array([ch])
        }
    }
  }
  escaped
}
