# MoonBit 8 月黑客松结项 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在现有数据契约库上增加真实可复用的审计与基准工作流，使生产 MoonBit 源码达到 4,000+ 行，并完成边界测试、CI、文档和 Mooncakes 发布准备。

**Architecture:** Benchmark 和 Audit 都放在根 `lib` 包，与现有 `Schema`、`FieldValue`、`diff_schemas`、`check_compatibility` 和导出器共享类型，避免循环依赖。CLI 通过 `moonbitlang/core/env.args()` 进入已有 `lib/cli`，Benchmark 使用 `moonbitlang/core/bench` 的单调时钟，报告使用纯字符串构造，便于 wasm-gc/native/js/wasm 全目标运行。

**Tech Stack:** MoonBit stable 0.10.7+ compiler line, `moonbitlang/core/bench`, `moonbitlang/core/env`, existing root `lib` package, GitHub Actions, PowerShell benchmark script.

## Global Constraints

- 只统计排除 `_build` 后的 `.mbt`；production 行数和 test 行数分开报告。
- 新增生产代码必须先有失败测试；测试不得依赖 mock 来替代真实核心逻辑。
- 不添加未经 `moon ide doc` 或 `moon tree` 确认的依赖。
- 所有顶层 MoonBit block 使用 `///|`，公共 API 通过 `moon info` 生成接口。
- CI 使用最新 stable 安装脚本，执行三平台全目标检查与测试。
- 赛事文案统一为 8 月黑客松；不得把 OSC2026 写成参赛归属。
- 推送/发布前必须直接核验 GitHub 和 Mooncakes 当前授权账号；不读取历史缓存账号。

---

### Task 1: Add benchmark data model and deterministic workloads

**Files:**
- Create: `lib/benchmark_types.mbt`
- Create: `lib/benchmark_fixtures.mbt`
- Create: `lib/benchmark_test.mbt`

**Interfaces:**
- Produces `BenchmarkWorkload`, `BenchmarkMeasurement`, `BenchmarkReport`, `standard_benchmark_workloads`, `run_workload` and `render_benchmark_markdown` for later tasks.

- [ ] **Step 1: Write the failing test**

Add tests that call `standard_benchmark_workloads()`, assert at least four named workloads, assert every workload has positive iterations, and assert `run_workload` returns a measurement whose `operations` equals the workload iteration count and whose elapsed microseconds is non-negative.

- [ ] **Step 2: Run the focused test to verify it fails**

Run: `moon test lib/benchmark_test.mbt`

Expected: compilation failure because `standard_benchmark_workloads` and the benchmark result types do not exist.

- [ ] **Step 3: Write minimal implementation**

Define `BenchmarkWorkload` with `name`, `iterations`, `schema`, `payload`, and `operation` fields; define `BenchmarkMeasurement` with `name`, `iterations`, `operations`, `elapsed_us`, `valid_count`, and `invalid_count`; define `BenchmarkReport` with `measurements`, `total_operations`, and `total_elapsed_us`. Build deterministic workloads for validation, diff, compatibility, and SQL/TypeScript export using existing public functions. Measure with `@bench.monotonic_clock_start()` and `@bench.monotonic_clock_end(start)`, using the verified microsecond unit.

- [ ] **Step 4: Run focused and package tests**

Run: `moon test lib/benchmark_test.mbt`

Expected: focused tests pass. Then run `moon check --deny-warn` and `moon test --deny-warn`.

- [ ] **Step 5: Commit**

Run: `git add lib/benchmark_types.mbt lib/benchmark_fixtures.mbt lib/benchmark_test.mbt; git commit -m "feat: add deterministic contract benchmark workloads"`

### Task 2: Add benchmark execution and report rendering

**Files:**
- Create: `lib/benchmark_runner.mbt`
- Modify: `lib/benchmark_test.mbt`

**Interfaces:**
- Consumes `BenchmarkWorkload` from Task 1.
- Produces `run_standard_benchmark() -> BenchmarkReport`, `BenchmarkReport::total_elapsed() -> Double`, `BenchmarkReport::to_markdown() -> String`, and `BenchmarkReport::to_json() -> String`.

- [ ] **Step 1: Write the failing test**

Add tests asserting `run_standard_benchmark()` has one measurement per standard workload, total operations equal the sum of measurement operations, Markdown includes the workload names and `elapsed_us`, and JSON includes `total_operations`.

- [ ] **Step 2: Run the test and verify the expected failure**

Run: `moon test lib/benchmark_test.mbt --filter 'benchmark report'`

Expected: compilation failure because `run_standard_benchmark` and report methods do not exist.

- [ ] **Step 3: Implement the minimal runner and renderers**

Run each workload, accumulate counters, and render stable field order. Do not include wall-clock timestamps in the core report; timestamps belong to the external benchmark evidence script so unit snapshots remain deterministic.

- [ ] **Step 4: Verify green and format**

Run: `moon test lib/benchmark_test.mbt --filter 'benchmark report'`, then `moon fmt` and `moon test --deny-warn`.

- [ ] **Step 5: Commit**

Run: `git add lib/benchmark_runner.mbt lib/benchmark_test.mbt; git commit -m "feat: add benchmark reports and aggregation"`

### Task 3: Add contract audit findings and boundary coverage

**Files:**
- Create: `lib/audit_types.mbt`
- Create: `lib/audit_engine.mbt`
- Create: `lib/audit_test.mbt`
- Modify: `lib/benchmark_fixtures.mbt`

**Interfaces:**
- Produces `AuditSeverity`, `AuditCode`, `AuditFinding`, `ContractAudit`, `audit_contract`, `ContractAudit::is_ready`, `ContractAudit::to_markdown` and deterministic edge fixtures.

- [ ] **Step 1: Write failing audit tests**

Cover: empty schema warning, missing required payload error, incompatible schema error, optional field addition success, unknown export target warning, duplicate-name detection, Unicode field names, and max/min boundary values.

- [ ] **Step 2: Run focused tests to verify failure**

Run: `moon test lib/audit_test.mbt`

Expected: compilation failure because audit types and `audit_contract` do not exist.

- [ ] **Step 3: Implement audit engine**

Create stable finding codes, run existing payload validation, schema diff, compatibility and export functions, collect findings without throwing on expected invalid input, and make `is_ready` false for errors only. Preserve all existing behavior and expose only the structured result.

- [ ] **Step 4: Run focused and full tests**

Run: `moon test lib/audit_test.mbt`, `moon check --deny-warn`, and `moon test --deny-warn`.

- [ ] **Step 5: Commit**

Run: `git add lib/audit_types.mbt lib/audit_engine.mbt lib/audit_test.mbt lib/benchmark_fixtures.mbt; git commit -m "feat: add contract acceptance audit"`

### Task 4: Integrate CLI and add end-to-end command tests

**Files:**
- Modify: `lib/cli/args.mbt`
- Modify: `lib/cli/commands.mbt`
- Modify: `lib/cli/cli_test.mbt`
- Modify: `cmd/main/main.mbt`
- Modify: `cmd/main/moon.pkg`

**Interfaces:**
- Adds `CmdBenchmark` and `CmdAudit` to the existing command enum.
- `parse_cli_args(["benchmark"])` returns `CmdBenchmark`; `parse_cli_args(["audit"])` returns `CmdAudit`.
- `moon run cmd/main -- benchmark` prints a benchmark report; `moon run cmd/main -- audit` prints an audit report.

- [ ] **Step 1: Write failing parser and CLI tests**

Add parser assertions for both commands and command runner assertions that the output contains `benchmark`/`audit` headings and stable summary fields.

- [ ] **Step 2: Run focused tests to verify failure**

Run: `moon test lib/cli/cli_test.mbt`

Expected: compilation failure because the new enum cases and runners do not exist.

- [ ] **Step 3: Implement command parsing and execution**

Add the enum cases, help text, and runner branches. Update `cmd/main/main.mbt` to read `@env.args()`, discard argv[0], parse the remaining values, and use the built-in demo Schema for commands requiring a schema. Keep the existing demo output for no arguments. Add the standard library env import to `cmd/main/moon.pkg` only if the compiler requires an explicit import.

- [ ] **Step 4: Verify commands**

Run: `moon test lib/cli/cli_test.mbt`, `moon run cmd/main -- benchmark`, and `moon run cmd/main -- audit`.

Expected: tests pass and both commands print structured reports without a panic.

- [ ] **Step 5: Commit**

Run: `git add lib/cli/args.mbt lib/cli/commands.mbt lib/cli/cli_test.mbt cmd/main/main.mbt cmd/main/moon.pkg; git commit -m "feat: expose audit and benchmark CLI commands"`

### Task 5: Add reproducible benchmark evidence and acceptance checks

**Files:**
- Create: `scripts/benchmark.ps1`
- Create: `scripts/verify_acceptance.ps1`
- Create: `benchmarks/README.md`
- Create: `benchmarks/latest.md`
- Modify: `.gitignore`

**Interfaces:**
- `scripts/benchmark.ps1` runs the native CLI benchmark repeatedly, captures elapsed wall-clock measurements, records `moon version --all`, OS, CPU, iteration count and output checksum, and writes `benchmarks/latest.md`.
- `scripts/verify_acceptance.ps1` checks production/test/total `.mbt` line counts, required files, and invokes check/test/format/info commands; it returns non-zero on failure.

- [ ] **Step 1: Write script fixtures/tests as executable acceptance checks**

Add explicit script assertions for missing root files, production line threshold, and required benchmark headings before implementing the final script body.

- [ ] **Step 2: Run the acceptance script against the current baseline**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify_acceptance.ps1`

Expected: it fails at the production line threshold before Tasks 1–4 add enough production functionality.

- [ ] **Step 3: Implement scripts and evidence document**

Use PowerShell `Get-ChildItem` to exclude `_build`, separate `*_test.mbt`/`*_wbtest.mbt`, run the Moon commands, and use `Measure-Command` around `moon run --target native cmd/main -- benchmark`. Store only measured values and environment metadata, not credentials or local paths.

- [ ] **Step 4: Run scripts after implementation**

Run: `powershell -ExecutionPolicy Bypass -File scripts/benchmark.ps1 -Runs 5`, then `powershell -ExecutionPolicy Bypass -File scripts/verify_acceptance.ps1`.

- [ ] **Step 5: Commit**

Run: `git add scripts benchmarks .gitignore; git commit -m "chore: add reproducible benchmark and acceptance checks"`

### Task 6: Refresh README, proposal, CI and publish workflow

**Files:**
- Modify: `README.md`
- Modify: `OSC2026_Hackathon_Proposal.md`
- Modify: `.github/workflows/ci.yml`
- Modify: `.github/workflows/copilot-setup-steps.yml`
- Create: `.github/workflows/publish.yml`
- Create: `CONTRIBUTING.md`
- Create: `SECURITY.md`

**Interfaces:**
- Documentation reports measured values from `benchmarks/latest.md` and exact reproducible commands.
- CI uses stable install, `moon version --all`, `moon update`, check/test `--target all`, format diff and info diff across three OSes.
- Publish is manual and uses `MOONCAKES_TOKEN`, with cleanup after publishing.

- [ ] **Step 1: Add documentation/CI assertions to the acceptance script**

Require README links to benchmark and acceptance scripts, the proposal to identify the August Hackathon, root Apache-2.0 license, and workflow files to contain `moon update`, `--target all`, `moon fmt`, and `moon info`.

- [ ] **Step 2: Run the assertion and observe the expected failure**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify_acceptance.ps1`

Expected: failure for at least the old OSC wording, old fixed version badge, or missing workflow markers.

- [ ] **Step 3: Implement docs and workflows**

Replace stale fixed metrics with current generated metrics, document the core API/CLI/benchmark output, distinguish the hackathon from OSC2026, and adapt the official community workflow templates to this repository. Keep publish token handling in GitHub Actions only.

- [ ] **Step 4: Run local YAML/content checks and Moon commands**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify_acceptance.ps1`, `moon fmt`, `moon info`, and `git diff --check`.

- [ ] **Step 5: Commit**

Run: `git add README.md OSC2026_Hackathon_Proposal.md .github CONTRIBUTING.md SECURITY.md; git commit -m "docs: finalize hackathon acceptance and CI workflows"`

### Task 7: Final verification, code review, identity checks and release

**Files:**
- Modify: `task_plan.md`
- Modify: `findings.md`
- Modify: `progress.md`

- [ ] **Step 1: Run the full local verification matrix**

Run in order: `moon version --all`, `moon update`, `moon fmt --check`, `moon check --deny-warn --target all`, `moon test --deny-warn --target all`, `moon build --target native`, `moon test --deny-warn --target native`, `moon info`, `git diff --check`, and `powershell -ExecutionPolicy Bypass -File scripts/verify_acceptance.ps1`.

- [ ] **Step 2: Inspect evidence**

Check `git status --short`, generated `.mbti` diffs, production line count, benchmark report, `git log --format='%an <%ae>'`, and `git branch -vv`.

- [ ] **Step 3: Request read-only code review**

Review the final commit range against this plan, focusing on correctness, target portability, evidence integrity, CLI behavior, security of publish workflow, and test gaps. Fix Critical/Important findings and rerun the full matrix.

- [ ] **Step 4: Verify GitHub identity and default branch**

Run `gh auth status`, `gh api user --jq .login`, `gh repo view lyjttio/moon-data-contract --json nameWithOwner,defaultBranchRef,owner`, and `git remote show origin`. Stop if the authenticated login is not `lyjttio`, owner/repository is not `lyjttio/moon-data-contract`, or default branch is not the reviewed branch.

- [ ] **Step 5: Verify Mooncakes identity and dry run**

Run `moon login` only if the current login identity cannot be displayed without overwriting credentials; otherwise use the existing authorized session, then run `moon publish --dry-run`. Stop on namespace or account mismatch.

- [ ] **Step 6: Commit release metadata and push only after verification**

Run `git status --short`, `git diff --cached --check`, `git push origin main`, then query the remote branch and GitHub Actions state. Publish to Mooncakes using the authorized `moon publish` command only after GitHub push succeeds and identity checks match. Record outputs in `progress.md` without secrets.
