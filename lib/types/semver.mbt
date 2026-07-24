// MoonBit Data Contract - Semantic Versioning (SemVer) System

pub(all) struct SemVer {
  major : Int
  minor : Int
  patch : Int
  prerelease : String?
} derive(Debug, Eq)

pub fn SemVer::new(
  major : Int,
  minor : Int,
  patch : Int,
  prerelease~ : String? = None
) -> SemVer {
  { major, minor, patch, prerelease }
}

fn parse_int_simple(s : String) -> Int? {
  if s.length() == 0 {
    return None
  }
  let mut acc = 0
  for i = 0; i < s.length(); i = i + 1 {
    let ch = s[i]
    if ch >= '0' && ch <= '9' {
      acc = acc * 10 + (ch.to_int() - '0'.to_int())
    } else {
      return None
    }
  }
  Some(acc)
}

pub fn SemVer::parse(version_str : String) -> SemVer? {
  let parts : Array[String] = []
  let mut start_idx = 0
  for i = 0; i < version_str.length(); i = i + 1 {
    let ch = version_str[i]
    if ch == '.' || ch == '-' {
      if i > start_idx {
        parts.push(version_str[start_idx:i].to_owned())
      }
      start_idx = i + 1
    }
  }
  if version_str.length() > start_idx {
    parts.push(version_str[start_idx:version_str.length()].to_owned())
  }

  if parts.length() < 3 {
    return None
  }

  match (parse_int_simple(parts[0]), parse_int_simple(parts[1]), parse_int_simple(parts[2])) {
    (Some(maj), Some(min), Some(pat)) => {
      let pre = if parts.length() > 3 { Some(parts[3]) } else { None }
      Some(SemVer::new(maj, min, pat, prerelease=pre))
    }
    _ => None
  }
}

pub fn SemVer::to_string(self : SemVer) -> String {
  let base = self.major.to_string() + "." + self.minor.to_string() + "." + self.patch.to_string()
  match self.prerelease {
    Some(pre) => base + "-" + pre
    None => base
  }
}

pub fn SemVer::compare(self : SemVer, other : SemVer) -> Int {
  if self.major != other.major {
    return if self.major > other.major { 1 } else { -1 }
  }
  if self.minor != other.minor {
    return if self.minor > other.minor { 1 } else { -1 }
  }
  if self.patch != other.patch {
    return if self.patch > other.patch { 1 } else { -1 }
  }
  0
}

pub fn SemVer::bump_major(self : SemVer) -> SemVer {
  SemVer::new(self.major + 1, 0, 0)
}

pub fn SemVer::bump_minor(self : SemVer) -> SemVer {
  SemVer::new(self.major, self.minor + 1, 0)
}

pub fn SemVer::bump_patch(self : SemVer) -> SemVer {
  SemVer::new(self.major, self.minor, self.patch + 1)
}
