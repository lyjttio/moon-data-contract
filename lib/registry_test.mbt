///|
test "registry: register initial and evolution schema" {
  let reg = SchemaRegistry::new(default_level=Backward)

  let f_id = Field::new("id", DataType::Primitive(PrimitiveType::TInt))
  let f_email = Field::new(
    "email",
    DataType::Primitive(PrimitiveType::TString),
    required=false,
  )

  let s1 = Schema::new("user_contract", "UserContract", "1.0.0", "team", [f_id])
  let s2 = Schema::new("user_contract", "UserContract", "1.1.0", "team", [
    f_id, f_email,
  ])

  let res1 = reg.register(s1)
  assert_true(res1 is Ok(_))

  let res2 = reg.register(s2)
  assert_true(res2 is Ok(_))

  let versions = reg.list_versions("user_contract")
  assert_eq(versions.length(), 2)
  assert_eq(versions[0], "1.0.0")
  assert_eq(versions[1], "1.1.0")

  let latest = reg.get_latest("user_contract")
  assert_true(latest is Some(_))
  assert_eq(latest.unwrap().version, "1.1.0")
}

///|
test "registry: reject breaking schema registration" {
  let reg = SchemaRegistry::new(default_level=Backward)

  let f_id = Field::new("id", DataType::Primitive(PrimitiveType::TInt))
  let f_email = Field::new(
    "email",
    DataType::Primitive(PrimitiveType::TString),
    required=false,
  )

  let s1 = Schema::new("user_contract", "UserContract", "1.0.0", "team", [
    f_id, f_email,
  ])
  // s2 breaks compatibility by removing 'id'
  let s2_breaking = Schema::new(
    "user_contract",
    "UserContract",
    "2.0.0",
    "team",
    [f_email],
  )

  let res1 = reg.register(s1)
  assert_true(res1 is Ok(_))

  let res2 = reg.register(s2_breaking)
  assert_true(res2 is Err(_))
}
