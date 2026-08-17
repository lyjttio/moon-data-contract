// Actionable next steps derived from governance evidence.

///|
pub(all) enum RecommendationPriority {
  Info
  ActionRequired
  Critical
} derive(Debug, Eq)

///|
pub(all) struct GovernanceRecommendation {
  code : String
  priority : RecommendationPriority
  title : String
  action : String
  evidence : String
} derive(Debug, Eq)

///|
fn recommendation_priority_text(priority : RecommendationPriority) -> String {
  match priority {
    Info => "INFO"
    ActionRequired => "ACTION_REQUIRED"
    Critical => "CRITICAL"
  }
}

///|
fn add_recommendation(
  recommendations : Array[GovernanceRecommendation],
  code : String,
  priority : RecommendationPriority,
  title : String,
  action : String,
  evidence : String,
) -> Unit {
  recommendations.push({ code, priority, title, action, evidence })
}

///|
pub fn recommend_governance_actions(
  result : GovernanceResult,
  checklist : ReleaseChecklist,
) -> Array[GovernanceRecommendation] {
  let recommendations : Array[GovernanceRecommendation] = []
  if result.chain_report.issues.length() > 0 {
    add_recommendation(
      recommendations,
      "FIX_SNAPSHOT_CHAIN",
      Critical,
      "Repair the snapshot version chain",
      "publish a contiguous SemVer snapshot chain before release",
      result.chain_report.issues.length().to_string() + " chain issues",
    )
  }
  if result.metrics.blocking_count > 0 {
    add_recommendation(
      recommendations,
      "RESOLVE_BLOCKING_FINDINGS",
      Critical,
      "Resolve blocking policy findings",
      "change the target schema or record a bounded, reviewed exception",
      result.metrics.blocking_count.to_string() + " blocking findings",
    )
  }
  if result.metrics.manual_migrations > 0 {
    add_recommendation(
      recommendations,
      "REHEARSE_MANUAL_MIGRATION",
      ActionRequired,
      "Rehearse manual migration actions",
      "attach a backfill and rollback runbook before publication",
      result.metrics.manual_migrations.to_string() + " manual actions",
    )
  }
  if result.risk_score() > 50 {
    add_recommendation(
      recommendations,
      "REDUCE_RISK_BUDGET",
      ActionRequired,
      "Reduce the release risk score",
      "split the transition into smaller compatible schema versions",
      "risk score=" + result.risk_score().to_string(),
    )
  }
  for item in checklist.items {
    if !item.passed && item.code == "HUMAN_APPROVAL" {
      add_recommendation(
        recommendations,
        "COLLECT_APPROVAL",
        ActionRequired,
        "Collect the required human approval",
        "add a reviewer record with a reason and target version",
        item.detail,
      )
    }
  }
  if recommendations.length() == 0 {
    add_recommendation(
      recommendations,
      "READY_TO_RELEASE",
      Info,
      "Governance checks passed",
      "publish the reviewed schema and retain the generated reports",
      "all checklist items passed",
    )
  }
  recommendations
}

///|
pub fn recommendation_summary(
  subject : String,
  recommendations : Array[GovernanceRecommendation],
) -> String {
  let mut critical = 0
  let mut actions = 0
  for recommendation in recommendations {
    match recommendation.priority {
      Critical => critical += 1
      ActionRequired => actions += 1
      Info => ()
    }
  }
  "subject=" +
  subject +
  ", recommendations=" +
  recommendations.length().to_string() +
  ", critical=" +
  critical.to_string() +
  ", action_required=" +
  actions.to_string()
}

///|
pub fn recommendations_to_markdown(
  subject : String,
  recommendations : Array[GovernanceRecommendation],
) -> String {
  let mut output = "# Governance Recommendations\n\nSubject: `" +
    subject +
    "`\n\n"
  output = output + "| Priority | Code | Recommendation | Action | Evidence |\n"
  output = output + "| :--- | :--- | :--- | :--- | :--- |\n"
  for recommendation in recommendations {
    output = output +
      "| " +
      recommendation_priority_text(recommendation.priority) +
      " | `" +
      recommendation.code +
      "` | " +
      recommendation.title +
      " | " +
      recommendation.action +
      " | " +
      recommendation.evidence +
      " |\n"
  }
  output
}

///|
pub fn recommendation_count(
  recommendations : Array[GovernanceRecommendation],
  priority : RecommendationPriority,
) -> Int {
  let mut count = 0
  for recommendation in recommendations {
    if recommendation.priority == priority {
      count += 1
    }
  }
  count
}

///|
pub fn recommendation_codes(
  recommendations : Array[GovernanceRecommendation],
) -> String {
  let mut output = ""
  for i, recommendation in recommendations {
    if i > 0 {
      output = output + ","
    }
    output = output + recommendation.code
  }
  output
}

///|
pub fn recommendations_to_text(
  subject : String,
  recommendations : Array[GovernanceRecommendation],
) -> String {
  let mut output = "Governance recommendations for " + subject + "\n"
  for recommendation in recommendations {
    output = output +
      "[" +
      recommendation_priority_text(recommendation.priority) +
      "] " +
      recommendation.code +
      ": " +
      recommendation.action +
      " (" +
      recommendation.evidence +
      ")\n"
  }
  output
}

///|
pub fn recommendation_has_code(
  recommendations : Array[GovernanceRecommendation],
  code : String,
) -> Bool {
  for recommendation in recommendations {
    if recommendation.code == code {
      return true
    }
  }
  false
}

///|
pub fn recommendation_priority_rank(priority : RecommendationPriority) -> Int {
  match priority {
    Info => 1
    ActionRequired => 2
    Critical => 3
  }
}

///|
pub fn recommendation_highest_priority(
  recommendations : Array[GovernanceRecommendation],
) -> RecommendationPriority {
  let mut highest = RecommendationPriority::Info
  for recommendation in recommendations {
    if recommendation_priority_rank(recommendation.priority) >
      recommendation_priority_rank(highest) {
      highest = recommendation.priority
    }
  }
  highest
}

///|
pub fn recommendation_action_plan(
  recommendations : Array[GovernanceRecommendation],
) -> String {
  let mut output = ""
  for i, recommendation in recommendations {
    output = output + (i + 1).to_string() + ". " + recommendation.action + "\n"
  }
  output
}

///|
pub fn recommendation_has_priority(
  recommendations : Array[GovernanceRecommendation],
  priority : RecommendationPriority,
) -> Bool {
  recommendation_count(recommendations, priority) > 0
}

///|
pub fn recommendation_priority_label(
  priority : RecommendationPriority,
) -> String {
  match priority {
    Info => "informational follow-up"
    ActionRequired => "action required before release"
    Critical => "critical release blocker"
  }
}

///|
pub fn recommendation_priority_is_blocking(
  priority : RecommendationPriority,
) -> Bool {
  priority == Critical
}

///|
pub fn recommendations_to_json(
  subject : String,
  recommendations : Array[GovernanceRecommendation],
) -> String {
  let mut output = "{\"subject\":\"" +
    json_escape(subject) +
    "\",\"recommendations\":["
  for i, recommendation in recommendations {
    if i > 0 {
      output = output + ","
    }
    output = output +
      "{\"code\":\"" +
      json_escape(recommendation.code) +
      "\",\"priority\":\"" +
      recommendation_priority_text(recommendation.priority) +
      "\",\"title\":\"" +
      json_escape(recommendation.title) +
      "\",\"action\":\"" +
      json_escape(recommendation.action) +
      "\",\"evidence\":\"" +
      json_escape(recommendation.evidence) +
      "\"}"
  }
  output + "]}"
}
