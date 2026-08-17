///|
fn audit_has_code(audit : ContractAudit, code : String) -> Bool {
  for finding in audit.findings {
    if finding.code == code {
      return true
    }
  }
  false
}

///|
test "audit rejects an empty schema and duplicate fields" {
  let empty = Schema::new("empty", "Empty", "1.0.0", "test", [])
  let empty_audit = audit_contract(
    empty,
    empty,
    Map([]),
    CompatibilityLevel::Backward,
  )
  assert_true(audit_has_code(empty_audit, "EMPTY_SCHEMA"))
  assert_false(empty_audit.is_ready)

  let duplicate_field = Field::new(
    "id",
    DataType::Primitive(PrimitiveType::TInt),
  )
  let duplicate = Schema::new("duplicate", "Duplicate", "1.0.0", "test", [
    duplicate_field, duplicate_field,
  ])
  let duplicate_audit = audit_contract(
    duplicate,
    duplicate,
    { "id": FieldValue::VInt(1) },
    CompatibilityLevel::Backward,
  )
  assert_true(audit_has_code(duplicate_audit, "DUPLICATE_FIELD"))
  assert_false(duplicate_audit.is_ready)
}

///|
test "audit reports invalid payload and breaking evolution" {
  let base = standard_benchmark_workloads()[0].schema
  let evolved = Field::new(
    "id",
    DataType::Primitive(PrimitiveType::TString),
    primary_key=true,
  )
  let breaking = Schema::new(base.id, base.name, "2.0.0", base.owner, [
    evolved,
    base.fields[1],
    base.fields[2],
  ])
  let audit = audit_contract(
    base,
    breaking,
    { "name": FieldValue::VString("missing id") },
    CompatibilityLevel::Backward,
  )
  assert_true(audit_has_code(audit, "PAYLOAD_INVALID"))
  assert_true(audit_has_code(audit, "BREAKING_CHANGE"))
  assert_eq(audit.recommended_bump, "MAJOR")
  assert_false(audit.is_ready)
}

///|
test "audit accepts an optional evolution and boundary unicode payload" {
  let bounded = Field::new("名称", DataType::Primitive(PrimitiveType::TInt), constraint={
    min_value: Some(0.0),
    max_value: Some(100.0),
    pattern: None,
    allowed_values: None,
  })
  let base = Schema::new("unicode", "Unicode", "1.0.0", "test", [bounded])
  let added = Field::new(
    "optional_note",
    DataType::Primitive(PrimitiveType::TString),
    required=false,
  )
  let next = Schema::new("unicode", "Unicode", "1.1.0", "test", [bounded, added])
  let audit = audit_contract(
    base,
    next,
    { "名称": FieldValue::VInt(0) },
    CompatibilityLevel::Backward,
  )
  assert_true(audit.is_ready)
  assert_eq(audit.recommended_bump, "MINOR")
  assert_true(audit.to_markdown().contains("Contract Audit"))
}

///|
test "audit metrics inspect nested fields and constraint density" {
  let nested_field = Field::new(
    "profile",
    DataType::StructDef([
      Field::new("age", DataType::Primitive(PrimitiveType::TInt), constraint={
        min_value: Some(0.0),
        max_value: Some(120.0),
        pattern: None,
        allowed_values: None,
      }),
      Field::new("city", DataType::Primitive(PrimitiveType::TString)),
    ]),
  )
  let schema = Schema::new("nested", "Nested", "1.0.0", "test", [nested_field])
  let metrics = analyze_schema(schema)
  assert_eq(metrics.top_level_fields, 1)
  assert_eq(metrics.total_fields, 3)
  assert_eq(metrics.max_depth, 2)
  assert_eq(metrics.constrained_fields, 1)
}

///|
test "audit exposes risk and machine-readable summary" {
  let workload = standard_benchmark_workloads()[0]
  let audit = audit_contract(
    workload.schema,
    workload.next_schema,
    workload.payload,
    CompatibilityLevel::Backward,
  )
  assert_true(audit.has_code("EVOLUTION_COMPATIBLE"))
  assert_eq(audit.profile.total_fields, 3)
  assert_eq(audit.profile_complexity(), 5)
  assert_true(audit.profile_required_ratio() > 0.0)
  assert_true(audit.risk_score() <= 100)
  assert_true(audit.to_json().contains("recommended_bump"))
}
