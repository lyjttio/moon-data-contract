// MoonBit Data Contract - Dependency DAG & Topology Resolver

pub(all) struct DependencyNode {
  schema_id : String
  dependencies : Array[String]
} derive(Debug, Eq)

pub(all) struct DependencyGraph {
  nodes : Map[String, DependencyNode]
} derive(Debug, Eq)

pub fn DependencyGraph::new() -> DependencyGraph {
  { nodes: Map([]) }
}

pub fn DependencyGraph::add_node(
  self : DependencyGraph,
  schema_id : String,
  deps : Array[String]
) -> Unit {
  self.nodes.set(schema_id, { schema_id, dependencies: deps })
}

pub fn DependencyGraph::has_cycle(self : DependencyGraph) -> Bool {
  let visited : Map[String, Int] = Map([]) // 0 = unvisited, 1 = visiting, 2 = visited

  fn dfs(curr : String) -> Bool {
    match visited.get(curr) {
      Some(1) => return true // Cycle found
      Some(2) => return false
      _ => ()
    }

    visited.set(curr, 1)

    match self.nodes.get(curr) {
      Some(node) => {
        for i = 0; i < node.dependencies.length(); i = i + 1 {
          let dep = node.dependencies[i]
          if dfs(dep) {
            return true
          }
        }
      }
      None => ()
    }

    visited.set(curr, 2)
    false
  }

  // Iterate over keys using array of node keys
  let node_keys : Array[String] = []
  for _, node in self.nodes {
    node_keys.push(node.schema_id)
  }

  for i = 0; i < node_keys.length(); i = i + 1 {
    let key = node_keys[i]
    let state = visited.get(key)
    match state {
      None | Some(0) => {
        if dfs(key) {
          return true
        }
      }
      _ => ()
    }
  }

  false
}
