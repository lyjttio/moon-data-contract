// MoonBit Data Contract - Pretty Printer for Schema Specifications

pub fn print_contract_spec(schema : Schema) -> String {
  let mut spec = "contract " + schema.name + " {\n"
  spec = spec + "  id: \"" + schema.id + "\"\n"
  spec = spec + "  version: \"" + schema.version + "\"\n"
  spec = spec + "  owner: \"" + schema.owner + "\"\n\n"
  spec = spec + "  fields {\n"

  for i = 0; i < schema.fields.length(); i = i + 1 {
    let f = schema.fields[i]
    let req_str = if f.required { "required" } else { "optional" }
    let pk_str = if f.primary_key { " [primary_key]" } else { "" }
    spec = spec + "    " + f.name + ": " + f.field_type.to_string() + " (" + req_str + ")" + pk_str + ";\n"
  }

  spec = spec + "  }\n"
  spec = spec + "}\n"
  spec
}
