// MoonBit Data Contract & Schema Evolution Tool - CLI Executable

fn main {
  println("=========================================================")
  println("  moon-data-contract - MoonBit Schema & Evolution Tool  ")
  println("=========================================================")

  // 1. Build Sample Schema v1.0.0
  let f_id = @lib.Field::new(
    "id",
    @lib.DataType::Primitive(@lib.PrimitiveType::TInt),
    primary_key=true,
    description="Unique Identifier",
  )
  let f_name = @lib.Field::new(
    "name",
    @lib.DataType::Primitive(@lib.PrimitiveType::TString),
    required=true,
    description="User Full Name",
  )
  let s1 = @lib.Schema::new(
    "user_schema",
    "UserProfile",
    "1.0.0",
    "data_eng",
    [f_id, f_name],
  )

  println("\n[1] Schema v1.0.0 JSON Representation:")
  println(s1.to_json_string())

  // 2. Validate Payload
  let payload : Map[String, @lib.FieldValue] = {
    "id": @lib.FieldValue::VInt(1001),
    "name": @lib.FieldValue::VString("Alice"),
  }

  let val_res = @lib.validate_schema_payload(s1, payload)
  println("\n[2] Payload Validation against v1.0.0:")
  if val_res.is_valid {
    println("Status: PASSED ✅ (0 errors)")
  } else {
    println("Status: FAILED ❌ (" + val_res.errors.length().to_string() + " errors)")
  }

  // 3. Evolve to Schema v1.1.0 (Non-breaking: Add optional email)
  let f_email = @lib.Field::new(
    "email",
    @lib.DataType::Primitive(@lib.PrimitiveType::TString),
    required=false,
    description="User Contact Email",
  )
  let s2 = @lib.Schema::new(
    "user_schema",
    "UserProfile",
    "1.1.0",
    "data_eng",
    [f_id, f_name, f_email],
  )

  let report = @lib.check_compatibility(s1, s2, @lib.Backward)
  println("\n[3] Evolution Compatibility Check (v1.0.0 -> v1.1.0, BACKWARD):")
  println(report.to_json_summary())

  println("\n[4] Evolution Markdown Report Preview:")
  println(report.to_markdown())
}
