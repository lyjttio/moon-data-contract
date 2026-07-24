// MoonBit Data Contract & Schema Evolution Tool - Schema Evolution Compatibility Checker

///|
pub fn check_compatibility(
  v1 : Schema,
  v2 : Schema,
  level : CompatibilityLevel,
) -> EvolutionReport {
  let diffs = diff_schemas(v1, v2)
  let mut breaking_count = 0
  let mut non_breaking_count = 0

  for i = 0; i < diffs.length(); i = i + 1 {
    match diffs[i].impact {
      Breaking => breaking_count = breaking_count + 1
      NonBreaking => non_breaking_count = non_breaking_count + 1
    }
  }

  let is_compatible = match level {
    NoneLevel => true
    Backward | Forward | Full => breaking_count == 0
  }

  {
    schema_id: v1.id,
    v1_version: v1.version,
    v2_version: v2.version,
    is_compatible,
    level,
    diffs,
    breaking_count,
    non_breaking_count,
  }
}
