// MoonBit Data Contract - Batch Schema Comparator & Multi-Subject Matrix Builder

///|
pub(all) struct BatchCompareResult {
  subject_a : String
  subject_b : String
  is_identical : Bool
  diff_count : Int
} derive(Debug, Eq)

///|
pub fn batch_compare_schemas(
  schemas_a : Array[Schema],
  schemas_b : Array[Schema],
) -> Array[BatchCompareResult] {
  let results : Array[BatchCompareResult] = []

  for i = 0; i < schemas_a.length(); i = i + 1 {
    let s_a = schemas_a[i]
    for j = 0; j < schemas_b.length(); j = j + 1 {
      let s_b = schemas_b[j]
      let diffs = diff_schemas(s_a, s_b)
      results.push({
        subject_a: s_a.id,
        subject_b: s_b.id,
        is_identical: diffs.length() == 0,
        diff_count: diffs.length(),
      })
    }
  }

  results
}
