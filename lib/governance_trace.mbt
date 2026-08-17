// Deterministic pipeline trace for CI diagnostics and acceptance evidence.

///|
pub(all) enum GovernanceTraceEventKind {
  SnapshotLoaded
  ChainAnalyzed
  PolicyEvaluated
  MigrationPlanned
  ReportRendered
  ReleaseEvaluated
} derive(Debug, Eq)

///|
pub(all) struct GovernanceTraceEvent {
  kind : GovernanceTraceEventKind
  stage : String
  subject : String
  version : String
  detail : String
} derive(Debug, Eq)

///|
pub(all) struct GovernanceTrace {
  events : Array[GovernanceTraceEvent]
} derive(Debug, Eq)

///|
pub(all) struct TracedGovernanceResult {
  result : GovernanceResult
  trace : GovernanceTrace
} derive(Debug, Eq)

///|
pub fn GovernanceTrace::new() -> GovernanceTrace {
  { events: [] }
}

///|
fn trace_kind_text(kind : GovernanceTraceEventKind) -> String {
  match kind {
    SnapshotLoaded => "SNAPSHOT_LOADED"
    ChainAnalyzed => "CHAIN_ANALYZED"
    PolicyEvaluated => "POLICY_EVALUATED"
    MigrationPlanned => "MIGRATION_PLANNED"
    ReportRendered => "REPORT_RENDERED"
    ReleaseEvaluated => "RELEASE_EVALUATED"
  }
}

///|
fn trace_kind_stage(kind : GovernanceTraceEventKind) -> String {
  match kind {
    SnapshotLoaded => "snapshot"
    ChainAnalyzed => "chain"
    PolicyEvaluated => "policy"
    MigrationPlanned => "migration"
    ReportRendered => "report"
    ReleaseEvaluated => "release"
  }
}

///|
fn trace_kind_label(kind : GovernanceTraceEventKind) -> String {
  match kind {
    SnapshotLoaded => "Snapshot loaded"
    ChainAnalyzed => "Chain analyzed"
    PolicyEvaluated => "Policy evaluated"
    MigrationPlanned => "Migration planned"
    ReportRendered => "Report rendered"
    ReleaseEvaluated => "Release evaluated"
  }
}

///|
pub fn GovernanceTrace::record(
  self : GovernanceTrace,
  kind : GovernanceTraceEventKind,
  subject : String,
  version : String,
  detail : String,
) -> Unit {
  self.events.push({
    kind,
    stage: trace_kind_stage(kind),
    subject,
    version,
    detail,
  })
}

///|
pub fn GovernanceTrace::stage_count(
  self : GovernanceTrace,
  stage : String,
) -> Int {
  let mut count = 0
  for event in self.events {
    if event.stage == stage {
      count += 1
    }
  }
  count
}

///|
pub fn GovernanceTrace::kind_count(
  self : GovernanceTrace,
  kind : GovernanceTraceEventKind,
) -> Int {
  let mut count = 0
  for event in self.events {
    if event.kind == kind {
      count += 1
    }
  }
  count
}

///|
pub fn GovernanceTrace::to_markdown(self : GovernanceTrace) -> String {
  let mut output = "# Governance Pipeline Trace\n\n"
  output = output + "Events: " + self.events.length().to_string() + "\n\n"
  output = output + "| Stage | Subject | Version | Detail |\n"
  output = output + "| :--- | :--- | :--- | :--- |\n"
  for event in self.events {
    output = output +
      "| " +
      trace_kind_label(event.kind) +
      " | `" +
      event.subject +
      "` | `" +
      event.version +
      "` | " +
      event.detail +
      " |\n"
  }
  output
}

///|
pub fn GovernanceTrace::to_json(self : GovernanceTrace) -> String {
  let mut output = "{\"event_count\":" +
    self.events.length().to_string() +
    ",\"events\":["
  for i, event in self.events {
    if i > 0 {
      output = output + ","
    }
    output = output +
      "{\"kind\":\"" +
      trace_kind_text(event.kind) +
      "\",\"stage\":\"" +
      event.stage +
      "\",\"subject\":\"" +
      json_escape(event.subject) +
      "\",\"version\":\"" +
      json_escape(event.version) +
      "\",\"detail\":\"" +
      json_escape(event.detail) +
      "\"}"
  }
  output + "]}"
}

///|
pub fn GovernanceTrace::summary(self : GovernanceTrace) -> String {
  "events=" +
  self.events.length().to_string() +
  ", snapshots=" +
  self.stage_count("snapshot").to_string() +
  ", chain=" +
  self.stage_count("chain").to_string() +
  ", policy=" +
  self.stage_count("policy").to_string() +
  ", migration=" +
  self.stage_count("migration").to_string() +
  ", report=" +
  self.stage_count("report").to_string() +
  ", release=" +
  self.stage_count("release").to_string()
}

///|
pub fn trace_governance(
  store : SnapshotStore,
  subject : String,
  policy : GovernancePolicy,
  level : CompatibilityLevel,
) -> TracedGovernanceResult {
  let trace = GovernanceTrace::new()
  let snapshots = store.list(subject)
  for snapshot in snapshots {
    trace.record(
      SnapshotLoaded,
      subject,
      snapshot.schema.version,
      snapshot.source,
    )
  }
  let chain = analyze_snapshot_chain(snapshots)
  trace.record(
    ChainAnalyzed,
    subject,
    if chain.ordered_versions.length() == 0 {
      ""
    } else {
      chain.ordered_versions[chain.ordered_versions.length() - 1]
    },
    chain.issues.length().to_string() + " chain issues",
  )
  let result = govern_subject(store, subject, policy, level)
  for plan in result.migration_plans {
    trace.record(
      PolicyEvaluated,
      subject,
      plan.target_version,
      result.findings.length().to_string() + " findings",
    )
    trace.record(
      MigrationPlanned,
      subject,
      plan.target_version,
      plan.actions.length().to_string() + " actions",
    )
  }
  trace.record(
    ReportRendered,
    subject,
    if result.chain_report.ordered_versions.length() == 0 {
      ""
    } else {
      result.chain_report.ordered_versions[result.chain_report.ordered_versions.length() -
      1]
    },
    "markdown/json/junit",
  )
  trace.record(
    ReleaseEvaluated,
    subject,
    if result.chain_report.ordered_versions.length() == 0 {
      ""
    } else {
      result.chain_report.ordered_versions[result.chain_report.ordered_versions.length() -
      1]
    },
    "allowed=" + result.is_release_allowed().to_string(),
  )
  { result, trace }
}
