test "compat: transitive compatibility across version chain" {
  let f1 = Field::new("id", DataType::Primitive(PrimitiveType::TInt))
  let f2 = Field::new("email", DataType::Primitive(PrimitiveType::TString), required=false)
  let f3 = Field::new("phone", DataType::Primitive(PrimitiveType::TString), required=false)

  let s1 = Schema::new("user", "User", "1.0.0", "team", [f1])
  let s2 = Schema::new("user", "User", "1.1.0", "team", [f1, f2])
  let s3 = Schema::new("user", "User", "1.2.0", "team", [f1, f2, f3])

  let res = check_transitive_compatibility([s1, s2, s3], Backward)
  assert_true(res.overall_compatible)
  assert_eq(res.version_chain.length(), 3)
}

test "compat: migration matrix generation" {
  let f1 = Field::new("id", DataType::Primitive(PrimitiveType::TInt))
  let f2 = Field::new("email", DataType::Primitive(PrimitiveType::TString), required=false)

  let s1 = Schema::new("user", "User", "1.0.0", "team", [f1])
  let s2 = Schema::new("user", "User", "1.1.0", "team", [f1, f2])

  let matrix = build_migration_matrix([s1, s2], Backward)
  assert_eq(matrix.versions.length(), 2)
  assert_eq(matrix.cells.length(), 2)
}
