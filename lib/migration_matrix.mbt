// MoonBit Data Contract - Multi-Version Migration Compatibility Matrix

///|
pub(all) struct MatrixCell {
  from_version : String
  to_version : String
  is_compatible : Bool
  breaking_count : Int
} derive(Debug, Eq)

///|
pub(all) struct MigrationMatrix {
  schema_id : String
  versions : Array[String]
  cells : Array[MatrixCell]
} derive(Debug, Eq)

///|
pub fn build_migration_matrix(
  schemas : Array[Schema],
  level : CompatibilityLevel,
) -> MigrationMatrix {
  let version_names : Array[String] = []
  let cells : Array[MatrixCell] = []

  for i = 0; i < schemas.length(); i = i + 1 {
    version_names.push(schemas[i].version)
  }

  for i = 0; i < schemas.length(); i = i + 1 {
    for j = 0; j < schemas.length(); j = j + 1 {
      if i != j {
        let v1 = schemas[i]
        let v2 = schemas[j]
        let report = check_compatibility(v1, v2, level)
        cells.push({
          from_version: v1.version,
          to_version: v2.version,
          is_compatible: report.is_compatible,
          breaking_count: report.breaking_count,
        })
      }
    }
  }

  let schema_id = if schemas.length() > 0 { schemas[0].id } else { "" }
  { schema_id, versions: version_names, cells }
}
