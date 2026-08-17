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
  ]
}
