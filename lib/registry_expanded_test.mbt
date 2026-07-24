test "dependency_graph: cycle detection" {
  let graph = DependencyGraph::new()
  graph.add_node("OrderService", ["PaymentService", "UserService"])
  graph.add_node("PaymentService", ["UserService"])
  graph.add_node("UserService", [])

  assert_false(graph.has_cycle())

  // Add cyclic dependency: UserService -> OrderService
  graph.add_node("UserService", ["OrderService"])
  assert_true(graph.has_cycle())
}

test "file_storage: filepath generation" {
  let cfg = FileStoreConfig::new("/var/schemas")
  let path = get_schema_filepath(cfg, "user_event", "1.0.0")
  assert_eq(path, "/var/schemas/user_event-1.0.0.json")
}
