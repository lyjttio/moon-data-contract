test "ast_node: count total nodes" {
  let f1 = ContractAstNode::new(NodeField, "id")
  let f2 = ContractAstNode::new(NodeField, "name")
  let root = ContractAstNode::new(NodeSchema, "UserSchema", children=[f1, f2])

  assert_eq(count_total_ast_nodes(root), 3)
}

test "contract_printer: print contract spec" {
  let f1 = Field::new("id", DataType::Primitive(PrimitiveType::TInt), primary_key=true)
  let schema = Schema::new("user_101", "UserProfile", "1.0.0", "team", [f1])

  let spec = print_contract_spec(schema)
  assert_true(spec.contains("contract UserProfile"))
  assert_true(spec.contains("id: int (required) [primary_key]"))
}
