// Representative workloads used by tests, the CLI, and the evidence script.

///|
fn benchmark_small_schema() -> Schema {
  let id = Field::new(
    "id",
    DataType::Primitive(PrimitiveType::TInt),
    primary_key=true,
  )
  let name = Field::new(
    "name",
    DataType::Primitive(PrimitiveType::TString),
    required=true,
  )
  let score = Field::new(
    "score",
    DataType::Primitive(PrimitiveType::TDouble),
    required=false,
    constraint={
      min_value: Some(0.0),
      max_value: Some(100.0),
      pattern: None,
      allowed_values: None,
    },
  )
  Schema::new("benchmark_user", "BenchmarkUser", "1.0.0", "benchmark", [
    id, name, score,
  ])
}

///|
fn benchmark_small_evolved_schema() -> Schema {
  let base = benchmark_small_schema()
  let email = Field::new(
    "email",
    DataType::Primitive(PrimitiveType::TString),
    required=false,
  )
  Schema::new(base.id, base.name, "1.1.0", base.owner, [
    base.fields[0],
    base.fields[1],
    base.fields[2],
    email,
  ])
}

///|
fn benchmark_wide_schema() -> Schema {
  let fields : Array[Field] = []
  for i = 0; i < 24; i = i + 1 {
    fields.push(
      Field::new(
        "metric_" + i.to_string(),
        if i % 2 == 0 {
          DataType::Primitive(PrimitiveType::TInt)
        } else {
          DataType::Primitive(PrimitiveType::TString)
        },
        required=i % 3 == 0,
      ),
    )
  }
  Schema::new("benchmark_wide", "BenchmarkWide", "1.0.0", "benchmark", fields)
}

///|
fn benchmark_wide_payload(schema : Schema) -> Map[String, FieldValue] {
  let payload : Map[String, FieldValue] = Map([])
  for i = 0; i < schema.fields.length(); i = i + 1 {
    let field = schema.fields[i]
    if field.required {
      if i % 2 == 0 {
        payload[field.name] = FieldValue::VInt(i)
      } else {
        payload[field.name] = FieldValue::VString("value_" + i.to_string())
      }
    }
  }
  payload
}

///|
fn benchmark_governance_schema(
  version : String,
  fields : Array[Field],
) -> Schema {
  Schema::new("orders", "Orders", version, "benchmark-governance", fields)
}

///|
pub fn benchmark_governance_snapshots() -> Array[SchemaSnapshot] {
  let id = Field::new("id", Primitive(TInt), primary_key=true)
  let customer = Field::new("customer", Primitive(TString), required=true)
  let amount = Field::new("amount", Primitive(TDouble), required=false)
  let currency = Field::new("currency", Primitive(TString), required=false)
  let v1 = benchmark_governance_schema("1.0.0", [id, customer])
  let v2 = benchmark_governance_schema("1.1.0", [id, customer, amount])
  let v3 = benchmark_governance_schema("1.2.0", [id, customer, amount, currency])
  let v4 = benchmark_governance_schema("2.0.0", [
    id,
    customer,
    amount,
    currency,
    Field::new("region", Primitive(TString)),
  ])
  [
    SchemaSnapshot::new(
      "orders",
      v1,
      source="benchmark",
      created_at="2026-08-18T00:00:00Z",
    ),
    SchemaSnapshot::new(
      "orders",
      v2,
      source="benchmark",
      created_at="2026-08-18T00:01:00Z",
    ),
    SchemaSnapshot::new(
      "orders",
      v3,
      source="benchmark",
      created_at="2026-08-18T00:02:00Z",
    ),
    SchemaSnapshot::new(
      "orders",
      v4,
      source="benchmark",
      created_at="2026-08-18T00:03:00Z",
    ),
  ]
}

///|
pub fn benchmark_governance_store() -> SnapshotStore {
  let store = SnapshotStore::new()
  for snapshot in benchmark_governance_snapshots() {
    ignore(store.insert(snapshot))
  }
  store
}

///|
pub fn standard_benchmark_workloads() -> Array[BenchmarkWorkload] {
  let small = benchmark_small_schema()
  let evolved = benchmark_small_evolved_schema()
  let wide = benchmark_wide_schema()
  [
    {
      name: "validate-small",
      iterations: 120,
      schema: small,
      next_schema: evolved,
      payload: {
        "id": FieldValue::VInt(1001),
        "name": FieldValue::VString("Alice"),
        "score": FieldValue::VDouble(98.5),
      },
      operation: BenchmarkOperation::Validate,
    },
    {
      name: "validate-wide",
      iterations: 80,
      schema: wide,
      next_schema: wide,
      payload: benchmark_wide_payload(wide),
      operation: BenchmarkOperation::Validate,
    },
    {
      name: "diff-evolution",
      iterations: 160,
      schema: small,
      next_schema: evolved,
      payload: Map([]),
      operation: BenchmarkOperation::Diff,
    },
    {
      name: "compatibility-evolution",
      iterations: 160,
      schema: small,
      next_schema: evolved,
      payload: Map([]),
      operation: BenchmarkOperation::Compatibility,
    },
    {
      name: "snapshot-chain-scan",
      iterations: 64,
      schema: small,
      next_schema: evolved,
      payload: Map([]),
      operation: BenchmarkOperation::SnapshotChainScan,
    },
    {
      name: "policy-evaluation",
      iterations: 96,
      schema: small,
      next_schema: evolved,
      payload: Map([]),
      operation: BenchmarkOperation::PolicyEvaluation,
    },
    {
      name: "migration-planning",
      iterations: 72,
      schema: small,
      next_schema: evolved,
      payload: Map([]),
      operation: BenchmarkOperation::MigrationPlanning,
    },
    {
      name: "governance-reporting",
      iterations: 40,
      schema: small,
      next_schema: evolved,
      payload: Map([]),
      operation: BenchmarkOperation::GovernanceReporting,
    },
  ]
}
