// Aggregated release-governance result types.

///|
pub(all) enum GovernanceStatus {
  Ready
  NeedsApproval
  Blocked
} derive(Debug, Eq)

///|
pub(all) struct GovernanceMetrics {
  transition_count : Int
  finding_count : Int
  blocking_count : Int
  automatic_migrations : Int
  manual_migrations : Int
  integrity_issue_count : Int
  risk_score : Int
} derive(Debug, Eq)

///|
pub(all) struct GovernanceResult {
  subject : String
  status : GovernanceStatus
  decision : PolicyDecision
  chain_report : SnapshotChainReport
  findings : Array[PolicyFinding]
  migration_plans : Array[MigrationPlan]
  metrics : GovernanceMetrics
} derive(Debug, Eq)

///|
pub fn GovernanceResult::is_release_allowed(self : GovernanceResult) -> Bool {
  self.status == Ready
}

///|
pub fn GovernanceResult::risk_score(self : GovernanceResult) -> Int {
  self.metrics.risk_score
}

///|
pub fn GovernanceResult::blocking_findings(
  self : GovernanceResult,
) -> Array[PolicyFinding] {
  let blocking : Array[PolicyFinding] = []
  for finding in self.findings {
    if finding.blocking {
      blocking.push(finding)
    }
  }
  blocking
}
