// Offline human-approval evidence for release gates.

///|
pub(all) enum ApprovalDecision {
  Pending
  Approved
  Rejected
} derive(Debug, Eq)

///|
pub(all) struct ApprovalRecord {
  subject : String
  version : String
  reviewer : String
  decision : ApprovalDecision
  reason : String
} derive(Debug, Eq)

///|
pub fn ApprovalRecord::new(
  subject : String,
  version : String,
  reviewer : String,
  decision : ApprovalDecision,
  reason : String,
) -> ApprovalRecord {
  { subject, version, reviewer, decision, reason }
}

///|
pub(all) struct ApprovalLedger {
  records : Array[ApprovalRecord]
} derive(Debug, Eq)

///|
pub fn ApprovalLedger::new() -> ApprovalLedger {
  { records: [] }
}

///|
pub fn ApprovalLedger::submit(
  self : ApprovalLedger,
  record : ApprovalRecord,
) -> Result[Unit, String] {
  if record.subject.length() == 0 {
    return Err("Approval subject cannot be empty")
  }
  if record.version.length() == 0 {
    return Err("Approval version cannot be empty")
  }
  if record.reviewer.length() == 0 {
    return Err("Approval reviewer cannot be empty")
  }
  if record.reason.length() == 0 {
    return Err("Approval reason cannot be empty")
  }
  self.records.push(record)
  Ok(())
}

///|
pub fn ApprovalLedger::reviewer_count(
  self : ApprovalLedger,
  subject : String,
  version : String,
) -> Int {
  let reviewers : Map[String, Bool] = Map([])
  for record in self.records {
    if record.subject == subject && record.version == version {
      reviewers[record.reviewer] = true
    }
  }
  let mut count = 0
  for _ in reviewers {
    count += 1
  }
  count
}

///|
pub fn ApprovalLedger::has_approval(
  self : ApprovalLedger,
  subject : String,
  version : String,
) -> Bool {
  match self.latest(subject, version) {
    Some(record) => record.decision == ApprovalDecision::Approved
    None => false
  }
}

///|
pub fn ApprovalLedger::latest(
  self : ApprovalLedger,
  subject : String,
  version : String,
) -> ApprovalRecord? {
  let mut latest : ApprovalRecord? = None
  for record in self.records {
    if record.subject == subject && record.version == version {
      latest = Some(record)
    }
  }
  latest
}

///|
pub(all) struct ReleaseGate {
  allowed : Bool
  status : GovernanceStatus
  reason : String
  target_version : String
  approval_count : Int
} derive(Debug, Eq)

///|
pub fn evaluate_release_gate(
  governance : GovernanceResult,
  ledger : ApprovalLedger,
) -> ReleaseGate {
  let target_version = if governance.chain_report.ordered_versions.length() == 0 {
    ""
  } else {
    governance.chain_report.ordered_versions[governance.chain_report.ordered_versions.length() -
    1]
  }
  let approval_count = ledger.reviewer_count(governance.subject, target_version)
  match governance.status {
    Ready =>
      {
        allowed: true,
        status: Ready,
        reason: "governance passed without manual approval",
        target_version,
        approval_count,
      }
    Blocked =>
      {
        allowed: false,
        status: Blocked,
        reason: "release is blocked by governance findings",
        target_version,
        approval_count,
      }
    NeedsApproval => {
      let approved = ledger.has_approval(governance.subject, target_version)
      {
        allowed: approved,
        status: NeedsApproval,
        reason: if approved {
          "release approved by the latest reviewer record"
        } else {
          "release requires a reviewer approval record"
        },
        target_version,
        approval_count,
      }
    }
  }
}

///|
pub fn release_gate_summary(gate : ReleaseGate) -> String {
  "allowed=" +
  gate.allowed.to_string() +
  ", status=" +
  governance_status_text(gate.status) +
  ", target=" +
  gate.target_version +
  ", approvals=" +
  gate.approval_count.to_string() +
  ", reason=" +
  gate.reason
}
