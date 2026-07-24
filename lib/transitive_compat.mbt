// MoonBit Data Contract - Transitive Compatibility Checker Across Multi-Version Chains

pub(all) struct ChainCompatResult {
  schema_id : String
  version_chain : Array[String]
  overall_compatible : Bool
  failed_step : String?
  total_breaking : Int
} derive(Debug, Eq)

pub fn check_transitive_compatibility(
  versions : Array[Schema],
  level : CompatibilityLevel
) -> ChainCompatResult {
  if versions.length() <= 1 {
    let chain : Array[String] = []
    for i = 0; i < versions.length(); i = i + 1 {
      chain.push(versions[i].version)
    }
    return {
      schema_id: if versions.length() == 1 { versions[0].id } else { "" },
      version_chain: chain,
      overall_compatible: true,
      failed_step: None,
      total_breaking: 0,
    }
  }

  let chain : Array[String] = []
  let mut total_breaking = 0
  let mut failed_step : String? = None
  let mut overall_compatible = true

  for i = 0; i < versions.length(); i = i + 1 {
    chain.push(versions[i].version)
  }

  let latest_idx = versions.length() - 1
  let latest_schema = versions[latest_idx]

  // Check latest schema against all previous versions in the chain
  for i = 0; i < latest_idx; i = i + 1 {
    let prev = versions[i]
    let report = check_compatibility(prev, latest_schema, level)
    total_breaking = total_breaking + report.breaking_count
    if !report.is_compatible {
      overall_compatible = false
      failed_step = Some("Incompatible step: " + prev.version + " -> " + latest_schema.version)
      break
    }
  }

  {
    schema_id: latest_schema.id,
    version_chain: chain,
    overall_compatible,
    failed_step,
    total_breaking,
  }
}
