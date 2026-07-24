// MoonBit Data Contract - Value Coercion Engine

fn parse_int_simple(s : String) -> Int? {
  if s.length() == 0 { return None }
  let mut acc = 0
  for i = 0; i < s.length(); i = i + 1 {
    let ch = s[i]
    if ch >= '0' && ch <= '9' {
      acc = acc * 10 + (ch.to_int() - '0'.to_int())
    } else {
      return None
    }
  }
  Some(acc)
}

pub fn coerce_value_to_type(val : FieldValue, target_type : DataType) -> FieldValue? {
  match (val, target_type) {
    (VString(s), Primitive(TInt)) => {
      match parse_int_simple(s) {
        Some(n) => Some(VInt(n))
        None => None
      }
    }
    (VString(s), Primitive(TBool)) => {
      match s {
        "true" | "TRUE" | "1" => Some(VBool(true))
        "false" | "FALSE" | "0" => Some(VBool(false))
        _ => None
      }
    }
    (VInt(n), Primitive(TDouble)) => Some(VDouble(n.to_double()))
    (VInt(n), Primitive(TString)) => Some(VString(n.to_string()))
    (VDouble(d), Primitive(TString)) => Some(VString(d.to_string()))
    (VBool(b), Primitive(TString)) => Some(VString(b.to_string()))
    _ => Some(val)
  }
}
