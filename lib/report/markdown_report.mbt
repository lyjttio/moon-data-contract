// MoonBit Data Contract - Advanced Markdown Evolution Report Generator

pub(all) struct EvolutionDetail {
  field_name : String
  change_type : String
  is_breaking : Bool
  description : String
} derive(Debug, Eq)

pub(all) struct ContractReport {
  schema_id : String
  base_version : String
  target_version : String
  level_name : String
  is_compatible : Bool
  details : Array[EvolutionDetail]
} derive(Debug, Eq)

pub fn ContractReport::to_markdown(self : ContractReport) -> String {
  let mut md = "# 📋 Schema Evolution Audit Report\n\n"
  md = md + "## Contract Metadata\n\n"
  md = md + "| Parameter | Value |\n"
  md = md + "| :--- | :--- |\n"
  md = md + "| **Schema ID** | `" + self.schema_id + "` |\n"
  md = md + "| **Base Version** | `" + self.base_version + "` |\n"
  md = md + "| **Target Version** | `" + self.target_version + "` |\n"
  md = md + "| **Strategy Level** | `" + self.level_name + "` |\n"

  let status_str = if self.is_compatible {
    "PASSED ✅ (Compatible)"
  } else {
    "REJECTED ❌ (Incompatible Breaking Changes Detected)"
  }
  md = md + "| **Verification Status** | **" + status_str + "** |\n\n"

  if !self.is_compatible {
    md = md + "> [!CAUTION]\n"
    md = md + "> **BREAKING CHANGE ALERT**: Target version contains breaking changes violating " + self.level_name + " policy.\n\n"
  } else {
    md = md + "> [!NOTE]\n"
    md = md + "> Schema evolution meets compatibility standards. Safe to register and deploy.\n\n"
  }

  md = md + "## Change Summary & Breakdowns\n\n"
  md = md + "| Field Name | Change Kind | Breaking? | Description |\n"
  md = md + "| :--- | :--- | :--- | :--- |\n"

  for i = 0; i < self.details.length(); i = i + 1 {
    let d = self.details[i]
    let breaking_badge = if d.is_breaking { "🚨 YES" } else { "✨ NO" }
    md = md + "| `" + d.field_name + "` | " + d.change_type + " | " + breaking_badge + " | " + d.description + " |\n"
  }

  md
}
