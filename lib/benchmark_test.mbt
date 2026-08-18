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
  assert_eq(workloads.length(), 8)
  assert_eq(workloads[0].name, "validate-small")
  assert_eq(workloads[1].name, "validate-wide")
  assert_eq(workloads[2].name, "diff-evolution")
  assert_eq(workloads[3].name, "compatibility-evolution")
  assert_eq(workloads[4].name, "snapshot-chain-scan")
  assert_eq(workloads[5].name, "policy-evaluation")
  assert_eq(workloads[6].name, "migration-planning")
  assert_eq(workloads[7].name, "governance-reporting")
  assert_eq(workloads[0].schema.fields.length(), 3)
  assert_eq(workloads[1].schema.fields.length(), 24)
}

///|
test "benchmark report aggregates measurements and renders stable fields" {
  let report = run_standard_benchmark()
  assert_eq(report.measurements.length(), 8)
  assert_eq(report.total_operations, 792)
  assert_true(report.total_elapsed() >= 0.0)
  assert_eq(report.measurement_count(), 8)
  assert_true(report.total_throughput() >= 0.0)
  let markdown = report.to_markdown()
  assert_true(markdown.contains("validate-small"))
  assert_true(
    markdown.contains("elapsed_us") || markdown.contains("Elapsed (us)"),
  )
  let json = report.to_json()
  assert_true(json.contains("total_operations"))
  assert_true(json.contains("compatibility-evolution"))
  assert_true(json.contains("governance-reporting"))
}

///|
test "governance benchmark workloads execute real pipeline paths" {
  let workloads = standard_benchmark_workloads()
  for workload in workloads[4:] {
    let measurement = run_workload(workload)
    assert_eq(measurement.operations, workload.iterations)
    assert_eq(measurement.valid_count, workload.iterations)
    assert_eq(measurement.invalid_count, 0)
  }
}

///|
test "governance benchmark fixture includes widening and an exception profile" {
  let snapshots = benchmark_governance_snapshots()
  assert_eq(snapshots.length(), 4)
  match snapshots[2].schema.fields[2].field_type {
    Primitive(TDouble) => assert_true(true)
    _ => assert_true(false)
  }
  let policy = benchmark_governance_policy()
  assert_true(policy.exceptions.length() >= 2)
}
