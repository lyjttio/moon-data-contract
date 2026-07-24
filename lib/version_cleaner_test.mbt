///|
test "version_cleaner: retention policy cleanup" {
  let f1 = Field::new("id", DataType::Primitive(PrimitiveType::TInt))
  let s1 = Schema::new("u", "User", "1.0.0", "team", [f1])
  let s2 = Schema::new("u", "User", "2.0.0", "team", [f1])
  let s3 = Schema::new("u", "User", "3.0.0", "team", [f1])
  let s4 = Schema::new("u", "User", "4.0.0", "team", [f1])

  let policy = RetentionPolicy::{
    max_versions_to_keep: 2,
    keep_first_version: true,
  }
  let cleaned = clean_expired_versions([s1, s2, s3, s4], policy)

  assert_eq(cleaned.length(), 2)
  assert_eq(cleaned[0].version, "1.0.0")
  assert_eq(cleaned[1].version, "4.0.0")
}
