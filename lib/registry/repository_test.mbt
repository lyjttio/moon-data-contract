test "registry: repository subject management and tags" {
  let repo = SchemaRepository::new()
  repo.register_subject("OrderEvent", "1.0.0", tags=["finance", "order"])
  repo.register_subject("UserEvent", "2.0.0", tags=["user", "auth"])

  let finance_subs = repo.search_by_tag("finance")
  assert_eq(finance_subs.length(), 1)
  assert_eq(finance_subs[0], "OrderEvent")

  assert_true(repo.set_stable_version("OrderEvent", "1.0.0"))
}
