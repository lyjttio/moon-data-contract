// MoonBit Data Contract - Schema Version Retention Policy & Garbage Collector

///|
pub(all) struct RetentionPolicy {
  max_versions_to_keep : Int
  keep_first_version : Bool
} derive(Debug, Eq)

///|
pub fn RetentionPolicy::default() -> RetentionPolicy {
  { max_versions_to_keep: 10, keep_first_version: true }
}

///|
pub fn clean_expired_versions(
  versions : Array[Schema],
  policy : RetentionPolicy,
) -> Array[Schema] {
  if versions.length() <= policy.max_versions_to_keep {
    return versions
  }

  let result : Array[Schema] = []

  if policy.keep_first_version && versions.length() > 0 {
    result.push(versions[0])
  }

  let start_offset = versions.length() - policy.max_versions_to_keep + 1
  for i = start_offset; i < versions.length(); i = i + 1 {
    result.push(versions[i])
  }

  result
}
