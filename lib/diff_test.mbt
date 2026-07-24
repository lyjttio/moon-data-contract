test "diff: field added, removed, and type changed" {
  let f_id = Field::new("id", DataType::Primitive(PrimitiveType::TInt))
  let f_name = Field::new("name", DataType::Primitive(PrimitiveType::TString))
  let f_age = Field::new("age", DataType::Primitive(PrimitiveType::TInt), required=false)

  let s1 = Schema::new("user", "User", "1.0.0", "team", [f_id, f_name])
  
  // v2 removes 'name', changes 'id' to String, and adds optional 'age'
  let f_id_v2 = Field::new("id", DataType::Primitive(PrimitiveType::TString))
  let s2 = Schema::new("user", "User", "2.0.0", "team", [f_id_v2, f_age])

  let diffs = diff_schemas(s1, s2)
  assert_true(diffs.length() >= 3)

  let mut found_type_change = false
  let mut found_removal = false
  let mut found_addition = false

  for i = 0; i < diffs.length(); i = i + 1 {
    match diffs[i].kind {
      TypeChanged(_, _) => found_type_change = true
      FieldRemoved(_) => found_removal = true
      FieldAdded(_) => found_addition = true
      _ => ()
    }
  }

  assert_true(found_type_change)
  assert_true(found_removal)
  assert_true(found_addition)
}
