// MoonBit Data Contract - Semantic Version Bump Calculator

///|
pub(all) enum RecommendedBump {
  BumpMajor
  BumpMinor
  BumpPatch
  BumpNone
} derive(Debug, Eq)

///|
pub fn calculate_version_bump(diffs : Array[AstDiffNode]) -> RecommendedBump {
  let mut has_breaking = false
  let mut has_non_breaking = false

  for i = 0; i < diffs.length(); i = i + 1 {
    if diffs[i].is_breaking {
      has_breaking = true
    } else {
      has_non_breaking = true
    }
  }

  if has_breaking {
    BumpMajor
  } else if has_non_breaking {
    BumpMinor
  } else {
    BumpNone
  }
}

///|
pub fn calculate_total_risk_score(diffs : Array[AstDiffNode]) -> Int {
  let mut total = 0
  for i = 0; i < diffs.length(); i = i + 1 {
    total = total + diffs[i].risk_score
  }
  if total > 100 {
    100
  } else {
    total
  }
}
