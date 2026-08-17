///|
test "benchmark workloads are deterministic and executable" {
  let workloads = standard_benchmark_workloads()
  assert_true(workloads.length() >= 4)
  for workload in workloads {
    assert_true(workload.iterations > 0)
    let measurement = run_workload(workload)
    assert_eq(measurement.operations, workload.iterations)
    assert_true(measurement.elapsed_us >= 0.0)
    assert_true(measurement.is_consistent())
    assert_eq(
      measurement.valid_count + measurement.invalid_count,
      workload.iterations,
    )
  }
}

///|
test "benchmark workload names and sizes are stable" {
  let workloads = standard_benchmark_workloads()
  assert_eq(workloads[0].name, "validate-small")
  assert_eq(workloads[1].name, "validate-wide")
  assert_eq(workloads[2].name, "diff-evolution")
  assert_eq(workloads[3].name, "compatibility-evolution")
  assert_eq(workloads[0].schema.fields.length(), 3)
  assert_eq(workloads[1].schema.fields.length(), 24)
}

///|
test "benchmark report aggregates measurements and renders stable fields" {
  let report = run_standard_benchmark()
  assert_eq(report.measurements.length(), 4)
  assert_eq(report.total_operations, 520)
  assert_true(report.total_elapsed() >= 0.0)
  assert_eq(report.measurement_count(), 4)
  assert_true(report.total_throughput() >= 0.0)
  let markdown = report.to_markdown()
  assert_true(markdown.contains("validate-small"))
  assert_true(
    markdown.contains("elapsed_us") || markdown.contains("Elapsed (us)"),
  )
  let json = report.to_json()
  assert_true(json.contains("total_operations"))
  assert_true(json.contains("compatibility-evolution"))
}
