// MoonBit Data Contract - Enterprise Schema Repository & Tag Manager

pub(all) struct SubjectMetadata {
  subject_name : String
  latest_version : String
  stable_version : String?
  tags : Array[String]
} derive(Debug, Eq)

pub(all) struct SchemaRepository {
  subjects : Map[String, SubjectMetadata]
} derive(Debug, Eq)

pub fn SchemaRepository::new() -> SchemaRepository {
  { subjects: Map([]) }
}

pub fn SchemaRepository::register_subject(
  self : SchemaRepository,
  subject_name : String,
  version : String,
  tags~ : Array[String] = []
) -> Unit {
  match self.subjects.get(subject_name) {
    Some(meta) => {
      self.subjects.set(subject_name, {
        subject_name,
        latest_version: version,
        stable_version: meta.stable_version,
        tags,
      })
    }
    None => {
      self.subjects.set(subject_name, {
        subject_name,
        latest_version: version,
        stable_version: Some(version),
        tags,
      })
    }
  }
}

pub fn SchemaRepository::set_stable_version(
  self : SchemaRepository,
  subject_name : String,
  version : String
) -> Bool {
  match self.subjects.get(subject_name) {
    Some(meta) => {
      self.subjects.set(subject_name, {
        subject_name: meta.subject_name,
        latest_version: meta.latest_version,
        stable_version: Some(version),
        tags: meta.tags,
      })
      true
    }
    None => false
  }
}

pub fn SchemaRepository::search_by_tag(
  self : SchemaRepository,
  target_tag : String
) -> Array[String] {
  let matched : Array[String] = []
  for name, meta in self.subjects {
    for i = 0; i < meta.tags.length(); i = i + 1 {
      if meta.tags[i] == target_tag {
        matched.push(name)
        break
      }
    }
  }
  matched
}
