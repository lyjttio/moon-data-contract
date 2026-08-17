# Benchmark evidence

Run the reproducible contract benchmark from the repository root:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/benchmark.ps1 -Runs 5
```

The script records the current stable MoonBit toolchain, operating system,
CPU identifier, deterministic workload operation count, MoonBit monotonic-clock
measurements, and CLI wall-clock samples in `benchmarks/latest.md`. On Windows,
the script uses `wasm-gc` because the local MinGW runtime does not provide the
native `rand_s` symbol; Unix hosts use the native target.

The benchmark is intended to compare revisions on the same machine. It is not
a cross-machine performance promise: build caches, CPU frequency scaling and
background load can affect wall-clock results.

The MoonBit benchmark itself contains four application workloads:

- validating a small contract;
- validating a 24-field contract;
- diffing a compatible schema evolution;
- checking backward compatibility for the same evolution.
