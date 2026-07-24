// MoonBit Data Contract - Contract AST Visitor & Node Definitions

///|
pub(all) enum AstNodeType {
  NodeSchema
  NodeHeader
  NodeField
  NodeConstraint
} derive(Debug, Eq)

///|
pub(all) struct ContractAstNode {
  node_type : AstNodeType
  name : String
  children : Array[ContractAstNode]
} derive(Debug, Eq)

///|
pub fn ContractAstNode::new(
  node_type : AstNodeType,
  name : String,
  children? : Array[ContractAstNode] = [],
) -> ContractAstNode {
  { node_type, name, children }
}

///|
pub fn count_total_ast_nodes(root : ContractAstNode) -> Int {
  let mut count = 1
  for i = 0; i < root.children.length(); i = i + 1 {
    count = count + count_total_ast_nodes(root.children[i])
  }
  count
}
