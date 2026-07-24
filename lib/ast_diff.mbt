// MoonBit Data Contract - Deep AST Diff & Structural Comparison Engine

///|
pub(all) enum AstChangeType {
  AstFieldAdded
  AstFieldRemoved
  AstFieldTypeModified
  AstFieldConstraintModified
  AstEnumVariantAdded
  AstEnumVariantRemoved
  AstUnionVariantAdded
  AstUnionVariantRemoved
  AstMetadataChanged
} derive(Debug, Eq)

///|
pub(all) struct AstDiffNode {
  path : String
  change_type : AstChangeType
  old_value : String?
  new_value : String?
  is_breaking : Bool
  risk_score : Int
} derive(Debug, Eq)

///|
pub fn AstDiffNode::new(
  path : String,
  change_type : AstChangeType,
  old_value? : String? = None,
  new_value? : String? = None,
  is_breaking? : Bool = true,
  risk_score? : Int = 50,
) -> AstDiffNode {
  { path, change_type, old_value, new_value, is_breaking, risk_score }
}

///|
pub fn diff_data_types(
  path : String,
  t1 : DataType,
  t2 : DataType,
) -> Array[AstDiffNode] {
  let nodes : Array[AstDiffNode] = []

  match (t1, t2) {
    (EnumDef(v1), EnumDef(v2)) => {
      // Check removed enum values
      for i = 0; i < v1.length(); i = i + 1 {
        let val1 = v1[i]
        let mut found = false
        for j = 0; j < v2.length(); j = j + 1 {
          if v2[j] == val1 {
            found = true
            break
          }
        }
        if !found {
          nodes.push(
            AstDiffNode::new(
              path + "." + val1,
              AstEnumVariantRemoved,
              old_value=Some(val1),
              is_breaking=true,
              risk_score=80,
            ),
          )
        }
      }
      // Check added enum values
      for i = 0; i < v2.length(); i = i + 1 {
        let val2 = v2[i]
        let mut found = false
        for j = 0; j < v1.length(); j = j + 1 {
          if v1[j] == val2 {
            found = true
            break
          }
        }
        if !found {
          nodes.push(
            AstDiffNode::new(
              path + "." + val2,
              AstEnumVariantAdded,
              new_value=Some(val2),
              is_breaking=false,
              risk_score=10,
            ),
          )
        }
      }
    }
    _ =>
      if t1 != t2 {
        nodes.push(
          AstDiffNode::new(
            path,
            AstFieldTypeModified,
            old_value=Some(t1.to_string()),
            new_value=Some(t2.to_string()),
            is_breaking=true,
            risk_score=90,
          ),
        )
      }
  }

  nodes
}
