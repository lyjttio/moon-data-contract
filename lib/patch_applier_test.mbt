///|
test "patch_applier: apply schema patch transformations" {
  let f1 = Field::new("id", DataType::Primitive(PrimitiveType::TInt))
  let f2 = Field::new("name", DataType::Primitive(PrimitiveType::TString))
  let s1 = Schema::new("user", "User", "1.0.0", "team", [f1, f2])

  let f_email = Field::new(
    "email",
    DataType::Primitive(PrimitiveType::TString),
    required=false,
  )
  let patch = SchemaPatch::{
    target_schema_id: "user",
    target_version: "1.1.0",
    operations: [OpAddField(f_email), OpRemoveField("name")],
  }

  let s2 = apply_patch_to_schema(s1, patch)
  assert_eq(s2.version, "1.1.0")
  assert_eq(s2.fields.length(), 2)
  assert_eq(s2.fields[0].name, "id")
  assert_eq(s2.fields[1].name, "email")
}
