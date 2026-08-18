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
        if report.ordered_versions == ["1.0.0", "1.1.0", "1.2.0", "2.0.0"] &&
          report.issues.length() == 0 {
          valid_count += 1
        } else {
          invalid_count += 1
        }
      }
      BenchmarkOperation::PolicyEvaluation => {
        let snapshots = benchmark_governance_snapshots()
        let findings = evaluate_policy(
          benchmark_governance_policy(),
          snapshots[1].schema,
          snapshots[2].schema,
          CompatibilityLevel::Backward,
        )
        let mut has_type_exception = false
        let mut has_optional_addition = false
        for finding in findings {
          if finding.rule_id == "type-changed" && finding.exception_applied {
            has_type_exception = true
          }
          if finding.rule_id == "optional-field-added" {
            has_optional_addition = true
          }
        }
        if findings.length() == 2 && has_type_exception && has_optional_addition {
          valid_count += 1
        } else {
          invalid_count += 1
        }
      }
      BenchmarkOperation::MigrationPlanning => {
        let plan = plan_schema_migration(workload.schema, workload.next_schema)
        if plan.base_version == workload.schema.version &&
          plan.target_version == workload.next_schema.version &&
          plan.actions.length() == 1 &&
          plan.actions[0].kind == MigrationActionKind::AddOptionalField {
          valid_count += 1
        } else {
          invalid_count += 1
        }
      }
      BenchmarkOperation::GovernanceReporting => {
        let result = govern_subject(
          benchmark_governance_store(),
          "orders",
          benchmark_governance_policy(),
          CompatibilityLevel::Backward,
        )
        let markdown = result.to_markdown()
        let json = result.to_json()
        if markdown.contains("Contract Governance Report") &&
          markdown.contains("Migration plans") &&
          json.contains("migration_plans") &&
          json.contains("risk_score") {
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
