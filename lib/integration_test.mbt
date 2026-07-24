///|
test "integration: end-to-end data contract evolution lifecycle" {
  // Step 1: Create Schema Registry with BACKWARD policy
  let registry = SchemaRegistry::new(default_level=Backward)

  // Step 2: Define Schema v1.0.0
  let f_order_id = Field::new(
    "order_id",
    DataType::Primitive(PrimitiveType::TString),
    primary_key=true,
    description="Unique Order Identifier",
  )
  let f_amount = Field::new(
    "amount",
    DataType::Primitive(PrimitiveType::TDouble),
    required=true,
    constraint={
      min_value: Some(0.01),
      max_value: None,
      pattern: None,
      allowed_values: None,
    },
  )
  let s1 = Schema::new(
    "order_contract",
    "OrderContract",
    "1.0.0",
    "order_team",
    [f_order_id, f_amount],
  )

  // Register v1.0.0
  let reg1 = registry.register(s1)
  assert_true(reg1 is Ok(_))

  // Step 3: Validate incoming order payload against v1
  let payload : Map[String, FieldValue] = {
    "order_id": VString("ORD-2026-9901"),
    "amount": VDouble(199.50),
  }
  let val_result = validate_schema_payload(s1, payload)
  assert_true(val_result.is_valid)

  // Step 4: Evolve schema to v1.1.0 (Add optional discount code)
  let f_discount = Field::new(
    "discount_code",
    DataType::Primitive(PrimitiveType::TString),
    required=false,
  )
  let s2 = Schema::new(
    "order_contract",
    "OrderContract",
    "1.1.0",
    "order_team",
    [f_order_id, f_amount, f_discount],
  )

  // Register v1.1.0
  let reg2 = registry.register(s2)
  assert_true(reg2 is Ok(_))

  // Step 5: Check registry version list & latest
  let versions = registry.list_versions("order_contract")
  assert_eq(versions.length(), 2)
  assert_eq(versions[1], "1.1.0")

  // Step 6: Generate change report
  let report = check_compatibility(s1, s2, Backward)
  assert_true(report.is_compatible)
  assert_eq(report.non_breaking_count, 1)
  assert_eq(report.breaking_count, 0)
}
