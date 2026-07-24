///|
test "version_indexer: semver range matching" {
  let v1_0 = @types.SemVer::new(1, 0, 0)
  let v1_5 = @types.SemVer::new(1, 5, 0)
  let range = VersionRange::at_least(v1_0)

  assert_true(is_version_in_range(v1_5, range))

  let s1 = Schema::new("user", "User", "0.9.0", "team", [])
  let s2 = Schema::new("user", "User", "1.2.0", "team", [])
  let matched = filter_matching_schemas([s1, s2], range)

  assert_eq(matched.length(), 1)
  assert_eq(matched[0].version, "1.2.0")
}

///|
test "metadata_tags: pii classification" {
  let tag1 = classify_field_pii("email")
  assert_eq(tag1.category, PiiCategory::PiiEmail)
  assert_true(tag1.is_sensitive)

  let tag2 = classify_field_pii("amount")
  assert_eq(tag2.category, PiiCategory::PiiNone)
}
