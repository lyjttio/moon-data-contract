// MoonBit Data Contract - Data Governance & PII Metadata Classifier

///|
pub(all) enum PiiCategory {
  PiiNone
  PiiPersonalName
  PiiEmail
  PiiPhoneNumber
  PiiNationalId
  PiiCreditCard
} derive(Debug, Eq)

///|
pub(all) struct DataGovernanceTag {
  category : PiiCategory
  is_sensitive : Bool
  retention_days : Int
} derive(Debug, Eq)

///|
pub fn DataGovernanceTag::default() -> DataGovernanceTag {
  { category: PiiNone, is_sensitive: false, retention_days: 365 }
}

///|
pub fn classify_field_pii(field_name : String) -> DataGovernanceTag {
  let lower_name = field_name
  if lower_name == "name" ||
    lower_name == "full_name" ||
    lower_name == "user_name" {
    { category: PiiPersonalName, is_sensitive: true, retention_days: 180 }
  } else if lower_name == "email" || lower_name == "user_email" {
    { category: PiiEmail, is_sensitive: true, retention_days: 365 }
  } else if lower_name == "phone" || lower_name == "mobile" {
    { category: PiiPhoneNumber, is_sensitive: true, retention_days: 180 }
  } else {
    DataGovernanceTag::default()
  }
}
