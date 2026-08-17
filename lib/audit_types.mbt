// Structured findings for acceptance and CI contract checks.

///|
pub(all) enum AuditSeverity {
  AuditInfo
  AuditWarning
  AuditError
} derive(Debug, Eq)

///|
pub fn AuditSeverity::to_string(self : AuditSeverity) -> String {
  match self {
    AuditInfo => "INFO"
    AuditWarning => "WARNING"
    AuditError => "ERROR"
  }
}

///|
pub(all) struct AuditFinding {
  code : String
  severity : AuditSeverity
  field_name : String
  message : String
} derive(Debug, Eq)

///|
pub(all) struct AuditMetrics {
  top_level_fields : Int
  total_fields : Int
  max_depth : Int
  constrained_fields : Int
} derive(Debug, Eq)

///|
pub(all) struct ContractAudit {
  schema_id : String
  from_version : String
  to_version : String
  checked_fields : Int
  payload_valid : Bool
  compatible : Bool
  recommended_bump : String
  is_ready : Bool
  metrics : AuditMetrics
  profile : SchemaProfile
  findings : Array[AuditFinding]
} derive(Debug, Eq)

///|
pub fn ContractAudit::error_count(self : ContractAudit) -> Int {
  let mut count = 0
  for finding in self.findings {
    match finding.severity {
      AuditSeverity::AuditError => count += 1
      _ => ()
    }
  }
  count
}

///|
pub fn ContractAudit::warning_count(self : ContractAudit) -> Int {
  let mut count = 0
  for finding in self.findings {
    match finding.severity {
      AuditSeverity::AuditWarning => count += 1
      _ => ()
    }
  }
  count
}

///|
pub fn ContractAudit::has_code(self : ContractAudit, code : String) -> Bool {
  for finding in self.findings {
    if finding.code == code {
      return true
    }
  }
  false
}

///|
pub fn ContractAudit::risk_score(self : ContractAudit) -> Int {
  let score = self.error_count() * 50 + self.warning_count() * 10
  if score > 100 {
    100
  } else {
    score
  }
}

///|
pub fn ContractAudit::to_json(self : ContractAudit) -> String {
  "{\"schema_id\":\"" +
  self.schema_id +
  "\",\"from_version\":\"" +
  self.from_version +
  "\",\"to_version\":\"" +
  self.to_version +
  "\",\"checked_fields\":" +
  self.checked_fields.to_string() +
  ",\"payload_valid\":" +
  self.payload_valid.to_string() +
  ",\"compatible\":" +
  self.compatible.to_string() +
  ",\"recommended_bump\":\"" +
  self.recommended_bump +
  "\",\"is_ready\":" +
  self.is_ready.to_string() +
  ",\"risk_score\":" +
  self.risk_score().to_string() +
  "}"
}

///|
pub fn ContractAudit::profile_complexity(self : ContractAudit) -> Int {
  self.profile.complexity_score()
}

///|
pub fn ContractAudit::profile_required_ratio(self : ContractAudit) -> Double {
  self.profile.required_ratio()
}
