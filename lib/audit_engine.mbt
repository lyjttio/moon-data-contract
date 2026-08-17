// Acceptance audit built on the existing validator, diff, and compatibility engines.

///|
fn audit_add_finding(
  findings : Array[AuditFinding],
  code : String,
  severity : AuditSeverity,
  field_name : String,
  message : String,
) -> Unit {
  findings.push({ code, severity, field_name, message })
}

///|
pub fn audit_contract(
  current : Schema,
  next : Schema,
  payload : Map[String, FieldValue],
  level : CompatibilityLevel,
) -> ContractAudit {
  let findings : Array[AuditFinding] = []
  let names : Map[String, Bool] = Map([])
  for field in current.fields {
    match names.get(field.name) {
      Some(_) =>
        audit_add_finding(
          findings,
          "DUPLICATE_FIELD",
          AuditSeverity::AuditError,
          field.name,
          "Field name appears more than once in the current schema",
        )
      None => names[field.name] = true
    }
  }

  if current.fields.length() == 0 {
    audit_add_finding(
      findings,
      "EMPTY_SCHEMA",
      AuditSeverity::AuditWarning,
      "",
      "Schema has no fields and cannot validate a useful contract",
    )
  }

  let payload_result = validate_schema_payload(current, payload)
  if !payload_result.is_valid {
    audit_add_finding(
      findings,
      "PAYLOAD_INVALID",
      AuditSeverity::AuditError,
      "",
      "Payload validation returned " +
      payload_result.errors.length().to_string() +
      " error(s)",
    )
  }

  let evolution = check_compatibility(current, next, level)
  if !evolution.is_compatible {
    audit_add_finding(
      findings,
      "BREAKING_CHANGE",
      AuditSeverity::AuditError,
      "",
      "Schema evolution contains " +
      evolution.breaking_count.to_string() +
      " breaking change(s)",
    )
  } else if evolution.diffs.length() > 0 {
    audit_add_finding(
      findings,
      "EVOLUTION_COMPATIBLE",
      AuditSeverity::AuditInfo,
      "",
      "Schema evolution is compatible with " + level.to_string(),
    )
  }

  let recommended_bump = if evolution.breaking_count > 0 {
    "MAJOR"
  } else if evolution.diffs.length() > 0 {
    "MINOR"
  } else {
    "PATCH"
  }
  let mut has_error = false
  for finding in findings {
    match finding.severity {
      AuditSeverity::AuditError => has_error = true
      _ => ()
    }
  }
  {
    schema_id: current.id,
    from_version: current.version,
    to_version: next.version,
    checked_fields: current.fields.length(),
    payload_valid: payload_result.is_valid,
    compatible: evolution.is_compatible,
    recommended_bump,
    is_ready: current.fields.length() > 0 && !has_error,
    metrics: analyze_schema(current),
    profile: profile_schema(current),
    findings,
  }
}

///|
pub fn ContractAudit::to_markdown(self : ContractAudit) -> String {
  let mut output = "# Contract Audit\n\n"
  output = output + "- Schema: " + self.schema_id + "\n"
  output = output +
    "- Evolution: " +
    self.from_version +
    " -> " +
    self.to_version +
    "\n"
  output = output + "- Ready: " + self.is_ready.to_string() + "\n"
  output = output + "- Recommended bump: " + self.recommended_bump + "\n\n"
  output = output + self.profile.to_markdown() + "\n"
  output = output + "## Findings\n\n"
  if self.findings.length() == 0 {
    output = output + "- INFO: no findings\n"
  } else {
    for finding in self.findings {
      output = output +
        "- [" +
        finding.severity.to_string() +
        "] " +
        finding.code +
        ": " +
        finding.message +
        "\n"
    }
  }
  output
}
