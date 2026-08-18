// Offline release-governance orchestration.

///|
fn append_findings(
  destination : Array[PolicyFinding],
  source : Array[PolicyFinding],
) -> Unit {
  for finding in source {
    destination.push(finding)
  }
}

///|
fn append_actions(
  destination : Array[MigrationPlan],
  source : MigrationPlan,
) -> Unit {
  destination.push(source)
}

///|
fn capped_risk(value : Int) -> Int {
  if value > 100 {
    100
  } else if value < 0 {
    0
  } else {
    value
  }
}

///|
pub fn govern_subject(
  store : SnapshotStore,
  subject : String,
  policy : GovernancePolicy,
  level : CompatibilityLevel,
) -> GovernanceResult {
  let snapshots = store.list(subject)
  let chain_report = analyze_snapshot_chain(snapshots)
  let integrity_report = validate_snapshot_integrity(snapshots)
  let findings : Array[PolicyFinding] = []
  let plans : Array[MigrationPlan] = []
  let mut transitions = 0
  let mut automatic_migrations = 0
  let mut manual_migrations = 0
  let mut risk_score = chain_report.issues.length() * 20 +
    integrity_report.issues.length() * 20

  for i = 0; i + 1 < snapshots.length(); i = i + 1 {
    let base = snapshots[i].schema
    let target = snapshots[i + 1].schema
    let transition_findings = evaluate_policy(policy, base, target, level)
    append_findings(findings, transition_findings)
    let plan = plan_schema_migration(base, target)
    append_actions(plans, plan)
    transitions = transitions + 1
    automatic_migrations = automatic_migrations + plan.automatic_action_count()
    manual_migrations = manual_migrations + plan.manual_action_count()
    risk_score = risk_score + plan.manual_action_count() * 5
    for finding in transition_findings {
      if finding.blocking {
        risk_score = risk_score + 10
      } else {
        match finding.severity {
          Warning => risk_score = risk_score + 2
          _ => ()
        }
      }
    }
  }

  if risk_score > policy.max_risk_score {
    findings.push({
      rule_id: "chain-risk-budget-exceeded",
      field_name: "~chain",
      severity: Error,
      blocking: true,
      exception_applied: false,
      risk_score: risk_score - policy.max_risk_score,
      message: "Cumulative chain risk exceeded policy budget by " +
      (risk_score - policy.max_risk_score).to_string(),
    })
  }

  let decision = policy_decision(findings)
  let status : GovernanceStatus = if chain_report.issues.length() > 0 ||
    integrity_report.issues.length() > 0 ||
    decision == PolicyDecision::Blocked {
    GovernanceStatus::Blocked
  } else if decision == PolicyDecision::ApprovalRequired {
    GovernanceStatus::NeedsApproval
  } else {
    GovernanceStatus::Ready
  }
  {
    subject,
    status,
    decision,
    chain_report,
    findings,
    migration_plans: plans,
    metrics: {
      transition_count: transitions,
      finding_count: findings.length(),
      blocking_count: {
        let mut count = 0
        for finding in findings {
          if finding.blocking {
            count = count + 1
          }
        }
        count
      },
      automatic_migrations,
      manual_migrations,
      integrity_issue_count: integrity_report.issues.length(),
      risk_score: capped_risk(risk_score),
    },
  }
}
