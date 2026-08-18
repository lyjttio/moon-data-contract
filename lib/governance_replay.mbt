// Replayable governance execution for CI and release evidence.

///|
pub(all) enum GovernanceReplayMode {
  DryRun
  ReleaseCandidate
} derive(Debug, Eq)

///|
pub(all) struct GovernanceReplayRequest {
  subject : String
  policy : GovernancePolicy
  level : CompatibilityLevel
  mode : GovernanceReplayMode
} derive(Debug, Eq)

///|
pub fn GovernanceReplayRequest::new(
  subject : String,
  policy : GovernancePolicy,
  level : CompatibilityLevel,
  mode : GovernanceReplayMode,
) -> GovernanceReplayRequest {
  { subject, policy, level, mode }
}

///|
pub(all) struct GovernanceReplayStep {
  sequence : Int
  stage : String
  passed : Bool
  detail : String
} derive(Debug, Eq)

///|
pub(all) struct GovernanceReplay {
  result : GovernanceResult
  trace : GovernanceTrace
  checklist : ReleaseChecklist
  recommendations : Array[GovernanceRecommendation]
  steps : Array[GovernanceReplayStep]
  mode : GovernanceReplayMode
} derive(Debug, Eq)

///|
fn replay_mode_text(mode : GovernanceReplayMode) -> String {
  match mode {
    DryRun => "DRY_RUN"
    ReleaseCandidate => "RELEASE_CANDIDATE"
  }
}

///|
fn replay_step_passed(
  event : GovernanceTraceEvent,
  result : GovernanceResult,
) -> Bool {
  match event.kind {
    SnapshotLoaded
    | ChainAnalyzed
    | PolicyEvaluated
    | MigrationPlanned
    | ReportRendered => true
    ReleaseEvaluated => result.is_release_allowed()
  }
}

///|
pub fn replay_governance(
  store : SnapshotStore,
  request : GovernanceReplayRequest,
) -> GovernanceReplay {
  let traced = trace_governance(
    store,
    request.subject,
    request.policy,
    request.level,
  )
  let checklist = build_release_checklist(traced.result, ApprovalLedger::new())
  let recommendations = recommend_governance_actions(traced.result, checklist)
  let steps : Array[GovernanceReplayStep] = []
  for sequence, event in traced.trace.events {
    steps.push({
      sequence: sequence + 1,
      stage: event.stage,
      passed: replay_step_passed(event, traced.result),
      detail: event.detail,
    })
  }
  {
    result: traced.result,
    trace: traced.trace,
    checklist,
    recommendations,
    steps,
    mode: request.mode,
  }
}

///|
pub fn GovernanceReplay::failed_step_count(self : GovernanceReplay) -> Int {
  let mut count = 0
  for step in self.steps {
    if !step.passed {
      count += 1
    }
  }
  count
}

///|
pub fn GovernanceReplay::is_publishable(self : GovernanceReplay) -> Bool {
  self.result.is_release_allowed() &&
  self.checklist.is_ready() &&
  self.failed_step_count() == 0
}

///|
pub fn GovernanceReplay::step_count(self : GovernanceReplay) -> Int {
  self.steps.length()
}

///|
pub fn GovernanceReplay::has_stage(
  self : GovernanceReplay,
  stage : String,
) -> Bool {
  for step in self.steps {
    if step.stage == stage {
      return true
    }
  }
  false
}

///|
pub fn GovernanceReplay::mode_label(self : GovernanceReplay) -> String {
  replay_mode_text(self.mode)
}

///|
pub fn GovernanceReplay::recommendation_count(self : GovernanceReplay) -> Int {
  self.recommendations.length()
}

///|
pub fn GovernanceReplay::to_markdown(self : GovernanceReplay) -> String {
  let mut output = "# Governance Replay\n\n"
  output = output + "- Subject: `" + self.result.subject + "`\n"
  output = output + "- Mode: " + replay_mode_text(self.mode) + "\n"
  output = output + "- Publishable: " + self.is_publishable().to_string() + "\n"
  output = output +
    "- Failed steps: " +
    self.failed_step_count().to_string() +
    "\n\n"
  output = output +
    "| # | Stage | Passed | Detail |\n| ---: | :--- | :---: | :--- |\n"
  for step in self.steps {
    output = output +
      "| " +
      step.sequence.to_string() +
      " | `" +
      step.stage +
      "` | " +
      step.passed.to_string() +
      " | " +
      step.detail +
      " |\n"
  }
  output +
  "\n" +
  recommendations_to_markdown(self.result.subject, self.recommendations)
}

///|
pub fn GovernanceReplay::to_json(self : GovernanceReplay) -> String {
  let mut output = "{\"subject\":\"" +
    json_escape(self.result.subject) +
    "\",\"mode\":\"" +
    replay_mode_text(self.mode) +
    "\",\"publishable\":" +
    self.is_publishable().to_string() +
    ",\"failed_steps\":" +
    self.failed_step_count().to_string() +
    ",\"steps\":["
  for i, step in self.steps {
    if i > 0 {
      output = output + ","
    }
    output = output +
      "{\"sequence\":" +
      step.sequence.to_string() +
      ",\"stage\":\"" +
      json_escape(step.stage) +
      "\",\"passed\":" +
      step.passed.to_string() +
      ",\"detail\":\"" +
      json_escape(step.detail) +
      "\"}"
  }
  output + "]}"
}
