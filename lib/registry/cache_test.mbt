test "registry: schema cache hit and miss" {
  let cache = SchemaCache::new(max_capacity=10)
  let f1 = Field::new("id", DataType::Primitive(PrimitiveType::TInt))
  let schema = Schema::new("user_cached", "User", "1.0.0", "team", [f1])

  cache.put(schema)
  assert_eq(cache.size(), 1)

  let hit = cache.get("user_cached", "1.0.0")
  assert_true(hit is Some(_))
  assert_eq(hit.unwrap().id, "user_cached")

  let miss = cache.get("user_cached", "2.0.0")
  assert_true(miss is None)
}
