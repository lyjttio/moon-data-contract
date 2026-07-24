///|
test "type_widening: subtyping widening checks" {
  assert_true(is_type_widenable(PrimitiveKind::PInt, PrimitiveKind::PDouble))
  assert_true(is_type_widenable(PrimitiveKind::PInt, PrimitiveKind::PInt64))
  assert_false(is_type_widenable(PrimitiveKind::PString, PrimitiveKind::PInt))

  let t1 = DataType::Primitive(PrimitiveKind::PInt)
  let t2 = DataType::Primitive(PrimitiveKind::PDouble)
  assert_true(is_data_type_compatible(t1, t2))
}
