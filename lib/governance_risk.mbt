// Risk bands and compact metrics used by dashboards and release logs.

///|
pub(all) enum RiskBand {
  Low
  Medium
  High
  Critical
} derive(Debug, Eq)

///|
pub fn risk_band(score : Int) -> RiskBand {
  if score <= 20 {
    Low
  } else if score <= 50 {
    Medium
  } else if score <= 80 {
    High
  } else {
    Critical
  }
}

///|
pub fn risk_band_text(band : RiskBand) -> String {
  match band {
    Low => "LOW"
    Medium => "MEDIUM"
    High => "HIGH"
    Critical => "CRITICAL"
  }
}

///|
pub fn GovernanceMetrics::summary(self : GovernanceMetrics) -> String {
  "transitions=" +
  self.transition_count.to_string() +
  ", findings=" +
  self.finding_count.to_string() +
  ", blocking=" +
  self.blocking_count.to_string() +
  ", automatic_migrations=" +
  self.automatic_migrations.to_string() +
  ", manual_migrations=" +
  self.manual_migrations.to_string() +
  ", risk_score=" +
  self.risk_score.to_string()
}

///|
pub fn GovernanceMetrics::risk_band(self : GovernanceMetrics) -> RiskBand {
  risk_band(self.risk_score)
}

///|
pub fn GovernanceResult::risk_band(self : GovernanceResult) -> RiskBand {
  risk_band(self.risk_score())
}

///|
pub fn governance_risk_summary(result : GovernanceResult) -> String {
  "subject=" +
  result.subject +
  ", band=" +
  risk_band_text(result.risk_band()) +
  ", score=" +
  result.risk_score().to_string() +
  ", release_allowed=" +
  result.is_release_allowed().to_string()
}
