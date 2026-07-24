test "types: primitive and data type string formatting" {
  let p = PrimitiveKind::PInt
  assert_eq(p.to_string(), "int")
  assert_eq(PrimitiveKind::from_string("int64"), PrimitiveKind::PInt64)

  let t_arr = DataType::ArrayDef(DataType::Primitive(PrimitiveKind::PString))
  assert_eq(t_arr.to_string(), "array<string>")
}

test "types: semver parsing and comparison" {
  let v1_opt = SemVer::parse("1.2.3")
  assert_true(v1_opt is Some(_))
  let v1 = v1_opt.unwrap()
  assert_eq(v1.major, 1)
  assert_eq(v1.minor, 2)
  assert_eq(v1.patch, 3)

  let v2 = SemVer::new(1, 3, 0)
  assert_eq(v1.compare(v2), -1)

  let v3 = v1.bump_minor()
  assert_eq(v3.to_string(), "1.3.0")
}

test "types: field rule and schema header construction" {
  let rule = FieldRule::new("R-001", "email", severity=SeverityWarning)
  assert_eq(rule.rule_id, "R-001")

  let header = SchemaHeader::new("sch_101", "UserEvent", "2.1.0")
  assert_eq(header.id, "sch_101")
  assert_eq(header.version, "2.1.0")
}
