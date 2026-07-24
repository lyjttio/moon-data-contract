// MoonBit Data Contract - SemVer Range Indexer & Version Filter Engine

///|
pub(all) struct VersionRange {
  min_version : @types.SemVer?
  include_min : Bool
  max_version : @types.SemVer?
  include_max : Bool
} derive(Debug, Eq)

///|
pub fn VersionRange::any() -> VersionRange {
  { min_version: None, include_min: true, max_version: None, include_max: true }
}

///|
pub fn VersionRange::at_least(v : @types.SemVer) -> VersionRange {
  {
    min_version: Some(v),
    include_min: true,
    max_version: None,
    include_max: true,
  }
}

///|
pub fn is_version_in_range(v : @types.SemVer, range : VersionRange) -> Bool {
  match range.min_version {
    Some(min_v) => {
      let cmp = v.compare(min_v)
      if range.include_min {
        if cmp < 0 {
          return false
        }
      } else if cmp <= 0 {
        return false
      }
    }
    None => ()
  }

  match range.max_version {
    Some(max_v) => {
      let cmp = v.compare(max_v)
      if range.include_max {
        if cmp > 0 {
          return false
        }
      } else if cmp >= 0 {
        return false
      }
    }
    None => ()
  }

  true
}

///|
pub fn filter_matching_schemas(
  schemas : Array[Schema],
  range : VersionRange,
) -> Array[Schema] {
  let matched : Array[Schema] = []
  for i = 0; i < schemas.length(); i = i + 1 {
    let s = schemas[i]
    match @types.SemVer::parse(s.version) {
      Some(parsed) => if is_version_in_range(parsed, range) { matched.push(s) }
      None => ()
    }
  }
  matched
}
