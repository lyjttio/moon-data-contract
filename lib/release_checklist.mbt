// Release checklist derived from governance, migration, and approval evidence.

///|
pub(all) struct ReleaseChecklistItem {
  code : String
  label : String
  passed : Bool
  detail : String
} derive(Debug, Eq)

///|
pub(all) struct ReleaseChecklist {
  subject : String
  items : Array[ReleaseChecklistItem]
} derive(Debug, Eq)

///|
fn checklist_item(
  code : String,
  label : String,
  passed : Bool,
  detail : String,
) -> ReleaseChecklistItem {
  { code, label, passed, detail }
}

///|
pub fn build_release_checklist(
  result : GovernanceResult,
  ledger : ApprovalLedger,
) -> ReleaseChecklist {
  let items : Array[ReleaseChecklistItem] = []
  let chain_ok = result.chain_report.issues.length() == 0
  items.push(
    checklist_item(
      "SNAPSHOT_CHAIN",
      "Snapshot chain is contiguous",
      chain_ok,
      result.chain_report.issues.length().to_string() + " structural issues",
    ),
  )
  let policy_ok = result.blocking_findings().length() == 0
  items.push(
    checklist_item(
      "POLICY_GATE",
      "Policy has no blocking findings",
      policy_ok,
      result.metrics.blocking_count.to_string() + " blocking findings",
    ),
  )
  let rollback_ok = {
    let mut safe = true
    for plan in result.migration_plans {
      if !build_rollback_plan(plan).is_safe() {
        safe = false
      }
    }
    safe
  }
  items.push(
    checklist_item(
      "ROLLBACK_PLAN",
      "Every migration has a safe rollback",
      rollback_ok,
      result.metrics.manual_migrations.to_string() + " manual migration actions",
    ),
  )
  let risk_ok = result.risk_score() <= 50
  items.push(
    checklist_item(
      "RISK_BUDGET",
      "Risk score stays within release budget",
      risk_ok,
      "risk=" + result.risk_score().to_string(),
    ),
  )
  let approval_ok = match result.status {
    Ready => true
    Blocked => false
    NeedsApproval => {
      let target = result.chain_report.ordered_versions[result.chain_report.ordered_versions.length() -
        1]
      ledger.has_approval(result.subject, target)
    }
  }
  items.push(
    checklist_item(
      "HUMAN_APPROVAL",
      "Required human approval is recorded",
      approval_ok,
      "approval records=" +
      ledger
      .reviewer_count(
        result.subject,
        if result.chain_report.ordered_versions.length() == 0 {
          ""
        } else {
          result.chain_report.ordered_versions[result.chain_report.ordered_versions.length() -
          1]
        },
      )
      .to_string(),
    ),
  )
  items.push(
    checklist_item(
      "RELEASE_STATUS",
      "Governance status allows release",
      result.is_release_allowed(),
      governance_status_text(result.status),
    ),
  )
  { subject: result.subject, items }
}

///|
pub fn ReleaseChecklist::is_ready(self : ReleaseChecklist) -> Bool {
  for item in self.items {
    if !item.passed {
      return false
    }
  }
  true
}

///|
pub fn ReleaseChecklist::passed_count(self : ReleaseChecklist) -> Int {
  let mut count = 0
  for item in self.items {
    if item.passed {
      count += 1
    }
  }
  count
}

///|
pub fn ReleaseChecklist::to_markdown(self : ReleaseChecklist) -> String {
  let mut output = "# Release Checklist\n\n"
  output = output + "Subject: `" + self.subject + "`\n"
  output = output + "Ready: " + self.is_ready().to_string() + "\n"
  output = output +
    "Passed: " +
    self.passed_count().to_string() +
    "/" +
    self.items.length().to_string() +
    "\n\n"
  output = output + "| Check | Result | Detail |\n| :--- | :---: | :--- |\n"
  for item in self.items {
    let result = if item.passed { "PASS" } else { "FAIL" }
    output = output +
      "| `" +
      item.code +
      "` " +
      item.label +
      " | " +
      result +
      " | " +
      item.detail +
      " |\n"
  }
  output
}
