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
      BenchmarkOperation::SnapshotChainScan => {
        let report = analyze_snapshot_chain(benchmark_governance_snapshots())
        if report.ordered_versions.length() == 4 {
          valid_count += 1
        } else {
          invalid_count += 1
        }
      }
      BenchmarkOperation::PolicyEvaluation => {
        let findings = evaluate_policy(
          GovernancePolicy::strict(),
          workload.schema,
          workload.next_schema,
          CompatibilityLevel::Backward,
        )
        if findings.length() == 1 &&
          findings[0].rule_id == "optional-field-added" {
          valid_count += 1
        } else {
          invalid_count += 1
        }
      }
      BenchmarkOperation::MigrationPlanning => {
        let plan = plan_schema_migration(workload.schema, workload.next_schema)
        if plan.base_version == workload.schema.version &&
          plan.target_version == workload.next_schema.version {
          valid_count += 1
        } else {
          invalid_count += 1
        }
      }
      BenchmarkOperation::GovernanceReporting => {
        let result = govern_subject(
          benchmark_governance_store(),
          "orders",
          GovernancePolicy::strict(),
          CompatibilityLevel::Backward,
        )
        let report = result.to_markdown()
        if report.contains("Contract Governance Report") {
          valid_count += 1
        } else {
          invalid_count += 1
        }
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
