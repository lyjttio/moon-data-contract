// Deterministic, library-level benchmark primitives for contract workflows.

///|
pub(all) enum BenchmarkOperation {
  Validate
  Diff
  Compatibility
} derive(Debug, Eq)

///|
pub(all) struct BenchmarkWorkload {
  name : String
  iterations : Int
  schema : Schema
  next_schema : Schema
  payload : Map[String, FieldValue]
  operation : BenchmarkOperation
} derive(Debug, Eq)

///|
pub(all) struct BenchmarkMeasurement {
  name : String
  iterations : Int
  operations : Int
  elapsed_us : Double
  valid_count : Int
  invalid_count : Int
} derive(Debug, Eq)

///|
pub fn BenchmarkMeasurement::throughput(self : BenchmarkMeasurement) -> Double {
  if self.elapsed_us <= 0.0 {
    0.0
  } else {
    self.operations.to_double() * 1000000.0 / self.elapsed_us
  }
}

///|
pub fn BenchmarkMeasurement::is_consistent(self : BenchmarkMeasurement) -> Bool {
  self.operations == self.valid_count + self.invalid_count &&
  self.iterations == self.operations &&
  self.elapsed_us >= 0.0
}

///|
pub(all) struct BenchmarkReport {
  measurements : Array[BenchmarkMeasurement]
  total_operations : Int
  total_elapsed_us : Double
} derive(Debug, Eq)

///|
pub fn BenchmarkReport::total_elapsed(self : BenchmarkReport) -> Double {
  self.total_elapsed_us
}

///|
pub fn BenchmarkReport::measurement_count(self : BenchmarkReport) -> Int {
  self.measurements.length()
}

///|
pub fn BenchmarkReport::total_throughput(self : BenchmarkReport) -> Double {
  if self.total_elapsed_us <= 0.0 {
    0.0
  } else {
    self.total_operations.to_double() * 1000000.0 / self.total_elapsed_us
  }
}
