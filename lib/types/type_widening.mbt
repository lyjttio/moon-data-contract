// MoonBit Data Contract - Type Widening & Subtyping Compatibility Engine

///|
pub fn is_type_widenable(
  from_type : PrimitiveKind,
  to_type : PrimitiveKind,
) -> Bool {
  match (from_type, to_type) {
    (PInt, PInt64) => true
    (PInt, PDouble) => true
    (PInt64, PDouble) => true
    (PBool, PString) => true
    (PInt, PString) => true
    (PInt64, PString) => true
    (PDouble, PString) => true
    _ => from_type == to_type
  }
}

///|
pub fn is_data_type_compatible(t1 : DataType, t2 : DataType) -> Bool {
  match (t1, t2) {
    (Primitive(p1), Primitive(p2)) => is_type_widenable(p1, p2)
    (OptionalDef(inner1), OptionalDef(inner2)) =>
      is_data_type_compatible(inner1, inner2)
    (ArrayDef(inner1), ArrayDef(inner2)) =>
      is_data_type_compatible(inner1, inner2)
    _ => t1 == t2
  }
}
