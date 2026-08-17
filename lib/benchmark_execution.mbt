// Execute one deterministic benchmark workload.

///|
pub fn run_workload(workload : BenchmarkWorkload) -> BenchmarkMeasurement {
  let start = @bench.monotonic_clock_start()
  let mut valid_count = 0
  let mut invalid_count = 0
  for _ in 0..<workload.iterations {
    match workload.operation {
      BenchmarkOperation::Validate => {
        let result = validate_schema_payload(workload.schema, workload.payload)
        if result.is_valid {
          valid_count += 1
        } else {
          invalid_count += 1
        }
      }
      BenchmarkOperation::Diff => {
        ignore(diff_schemas(workload.schema, workload.next_schema))
        valid_count += 1
      }
      BenchmarkOperation::Compatibility => {
        ignore(
          check_compatibility(
            workload.schema,
            workload.next_schema,
            CompatibilityLevel::Backward,
          ),
        )
        valid_count += 1
      }
    }
  }
  let elapsed_us = @bench.monotonic_clock_end(start)
  {
    name: workload.name,
    iterations: workload.iterations,
    operations: workload.iterations,
    elapsed_us,
    valid_count,
    invalid_count,
  }
}
