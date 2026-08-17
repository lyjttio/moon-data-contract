// Benchmark execution and stable report rendering.

///|
pub fn run_standard_benchmark() -> BenchmarkReport {
  let measurements : Array[BenchmarkMeasurement] = []
  let mut total_operations = 0
  let mut total_elapsed_us = 0.0
  for workload in standard_benchmark_workloads() {
    let measurement = run_workload(workload)
    measurements.push(measurement)
    total_operations += measurement.operations
    total_elapsed_us += measurement.elapsed_us
  }
  { measurements, total_operations, total_elapsed_us }
}

///|
pub fn BenchmarkReport::to_markdown(self : BenchmarkReport) -> String {
  let mut output = "# Contract Benchmark Report\n\n"
  output = output +
    "| Workload | Operations | Elapsed (us) | Throughput (ops/s) |\n"
  output = output + "| --- | ---: | ---: | ---: |\n"
  for measurement in self.measurements {
    output = output +
      "| " +
      measurement.name +
      " | " +
      measurement.operations.to_string() +
      " | " +
      measurement.elapsed_us.to_string() +
      " | " +
      measurement.throughput().to_string() +
      " |\n"
  }
  output = output + "\n"
  output = output +
    "Total operations: " +
    self.total_operations.to_string() +
    "\n"
  output + "Total elapsed (us): " + self.total_elapsed_us.to_string() + "\n"
}

///|
pub fn BenchmarkReport::to_json(self : BenchmarkReport) -> String {
  let mut output = "{\"total_operations\":" +
    self.total_operations.to_string() +
    ",\"total_elapsed_us\":" +
    self.total_elapsed_us.to_string() +
    ",\"measurements\":["
  for i = 0; i < self.measurements.length(); i = i + 1 {
    let measurement = self.measurements[i]
    if i > 0 {
      output = output + ","
    }
    output = output +
      "{\"name\":\"" +
      measurement.name +
      "\",\"operations\":" +
      measurement.operations.to_string() +
      ",\"elapsed_us\":" +
      measurement.elapsed_us.to_string() +
      ",\"valid_count\":" +
      measurement.valid_count.to_string() +
      ",\"invalid_count\":" +
      measurement.invalid_count.to_string() +
      "}"
  }
  output + "]}"
}
