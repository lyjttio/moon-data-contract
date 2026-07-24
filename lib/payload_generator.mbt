// MoonBit Data Contract - Random Test Data Payload Generator

///|
pub fn generate_sample_field_value(field : Field, seed : Int) -> FieldValue {
  match field.field_type {
    Primitive(TBool) => VBool(seed % 2 == 0)
    Primitive(TInt) => VInt(100 + seed % 50)
    Primitive(TDouble) => VDouble((seed % 500).to_double() / 10.0)
    Primitive(TString) => VString(field.name + "_val_" + seed.to_string())
    OptionalDef(_) => VNull
    _ => VString("sample")
  }
}

///|
pub fn generate_sample_payload(
  schema : Schema,
  seed : Int,
) -> Map[String, FieldValue] {
  let map : Map[String, FieldValue] = Map([])
  for i = 0; i < schema.fields.length(); i = i + 1 {
    let f = schema.fields[i]
    let val = generate_sample_field_value(f, seed + i * 17)
    map.set(f.name, val)
  }
  map
}
