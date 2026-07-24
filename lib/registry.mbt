// MoonBit Data Contract & Schema Evolution Tool - Schema Registry & Version Manager

///|
pub(all) struct SchemaRegistry {
  schemas : Map[String, Array[Schema]]
  default_level : CompatibilityLevel
} derive(Debug, Eq)

///|
pub fn SchemaRegistry::new(
  default_level? : CompatibilityLevel = Backward,
) -> SchemaRegistry {
  { schemas: Map([]), default_level }
}

///|
pub fn SchemaRegistry::register(
  self : SchemaRegistry,
  schema : Schema,
) -> Result[Unit, String] {
  match self.schemas.get(schema.id) {
    None => {
      self.schemas.set(schema.id, [schema])
      Ok(())
    }
    Some(versions) => {
      let latest = versions[versions.length() - 1]
      let report = check_compatibility(latest, schema, self.default_level)
      if report.is_compatible {
        versions.push(schema)
        Ok(())
      } else {
        Err(
          "Registration rejected: Schema version " +
          schema.version +
          " violates " +
          self.default_level.to_string() +
          " compatibility with version " +
          latest.version,
        )
      }
    }
  }
}

///|
pub fn SchemaRegistry::get_latest(
  self : SchemaRegistry,
  id : String,
) -> Schema? {
  match self.schemas.get(id) {
    None => None
    Some(versions) =>
      if versions.length() == 0 {
        None
      } else {
        Some(versions[versions.length() - 1])
      }
  }
}

///|
pub fn SchemaRegistry::get_version(
  self : SchemaRegistry,
  id : String,
  version : String,
) -> Schema? {
  match self.schemas.get(id) {
    None => None
    Some(versions) => {
      for i = 0; i < versions.length(); i = i + 1 {
        if versions[i].version == version {
          return Some(versions[i])
        }
      }
      None
    }
  }
}

///|
pub fn SchemaRegistry::list_versions(
  self : SchemaRegistry,
  id : String,
) -> Array[String] {
  match self.schemas.get(id) {
    None => []
    Some(versions) => {
      let res : Array[String] = []
      for i = 0; i < versions.length(); i = i + 1 {
        res.push(versions[i].version)
      }
      res
    }
  }
}
