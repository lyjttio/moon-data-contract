// Multi-subject contract catalog built on top of SnapshotStore.

///|
pub(all) struct ContractCatalog {
  store : SnapshotStore
  subject_names : Array[String]
} derive(Debug, Eq)

///|
pub fn ContractCatalog::new() -> ContractCatalog {
  { store: SnapshotStore::new(), subject_names: [] }
}

///|
pub fn ContractCatalog::register(
  self : ContractCatalog,
  snapshot : SchemaSnapshot,
) -> Result[Unit, String] {
  let result = self.store.insert(snapshot)
  match result {
    Err(message) => Err(message)
    Ok(_) => {
      let mut known = false
      for subject in self.subject_names {
        if subject == snapshot.subject {
          known = true
        }
      }
      if !known {
        self.subject_names.push(snapshot.subject)
        self.subject_names.sort()
      }
      Ok(())
    }
  }
}

///|
pub fn ContractCatalog::subject_count(self : ContractCatalog) -> Int {
  self.subject_names.length()
}

///|
pub fn ContractCatalog::subjects(self : ContractCatalog) -> Array[String] {
  self.subject_names
}

///|
pub fn ContractCatalog::snapshots(
  self : ContractCatalog,
  subject : String,
) -> Array[SchemaSnapshot] {
  self.store.list(subject)
}

///|
pub fn ContractCatalog::govern_subject(
  self : ContractCatalog,
  subject : String,
  policy : GovernancePolicy,
  level : CompatibilityLevel,
) -> GovernanceResult {
  govern_subject(self.store, subject, policy, level)
}

///|
pub fn ContractCatalog::govern_all(
  self : ContractCatalog,
  policy : GovernancePolicy,
  level : CompatibilityLevel,
) -> Array[GovernanceResult] {
  let results : Array[GovernanceResult] = []
  for subject in self.subject_names {
    results.push(govern_subject(self.store, subject, policy, level))
  }
  results
}

///|
pub fn catalog_risk_total(results : Array[GovernanceResult]) -> Int {
  let mut total = 0
  for result in results {
    total += result.risk_score()
  }
  total
}

///|
pub fn catalog_release_ready(results : Array[GovernanceResult]) -> Bool {
  for result in results {
    if !result.is_release_allowed() {
      return false
    }
  }
  true
}

///|
pub fn catalog_summary(catalog : ContractCatalog) -> String {
  let mut versions = 0
  for subject in catalog.subject_names {
    versions += catalog.store.list(subject).length()
  }
  "subjects=" +
  catalog.subject_count().to_string() +
  ", snapshots=" +
  versions.to_string() +
  ", subjects_indexed=" +
  catalog.subject_names.join(",")
}
