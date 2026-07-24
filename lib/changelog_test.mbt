///|
test "changelog: build release migration markdown" {
  let diff1 = DiffEntry::{
    field_name: "old_col",
    kind: FieldRemoved(
      Field::new("old_col", DataType::Primitive(PrimitiveType::TString)),
    ),
    impact: Breaking,
    description: "Field old_col was removed",
  }
  let log = build_changelog("user_schema", "1.0.0", "2.0.0", [diff1])
  let md = log.to_markdown()

  assert_true(md.contains("Release Migration Notes: user_schema"))
  assert_true(md.contains("Breaking Changes"))
  assert_true(md.contains("Field 'old_col': Field old_col was removed"))
}
