// MoonBit Data Contract - JUnit XML Exporter for CI Verification

///|
pub fn export_junit_xml(
  schema_id : String,
  is_compatible : Bool,
  breaking_count : Int,
  details : Array[EvolutionDetail],
) -> String {
  let mut xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  let tests_count = details.length()
  let failures_count = if is_compatible { 0 } else { breaking_count }

  xml = xml +
    "<testsuite name=\"schema-evolution-" +
    schema_id +
    "\" tests=\"" +
    tests_count.to_string() +
    "\" failures=\"" +
    failures_count.to_string() +
    "\">\n"

  for i = 0; i < details.length(); i = i + 1 {
    let d = details[i]
    xml = xml +
      "  <testcase name=\"" +
      d.field_name +
      "-" +
      d.change_type +
      "\" classname=\"" +
      schema_id +
      "\">\n"
    if d.is_breaking {
      xml = xml +
        "    <failure message=\"Breaking Change Violation\">" +
        d.description +
        "</failure>\n"
    }
    xml = xml + "  </testcase>\n"
  }

  xml = xml + "</testsuite>\n"
  xml
}
