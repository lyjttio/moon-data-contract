# Offline Contract Governance Expansion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extend `moon-data-contract` with an offline Schema governance pipeline and reach 7,200–7,600 lines of effective production MoonBit source through reusable snapshot, policy, migration, governance, reporting, CLI, and benchmark functionality.

**Architecture:** Build six focused capabilities inside the existing root `lib` package: immutable schema snapshots, policy evaluation, migration planning, governance aggregation, deterministic reports, and CLI/benchmark integration. Reuse the existing `Schema`, `diff_schemas`, `check_compatibility`, `SchemaRegistry`, and report conventions; do not add network services or unverified dependencies.

**Tech Stack:** MoonBit stable toolchain; existing `lyjttio/moon-data-contract/lib` and `lib/types`; `moonbitlang/core/bench`; wasm, wasm-gc, js, and CI-covered native targets; PowerShell evidence scripts; generated `.mbti` interfaces from `moon info`.

## Global Constraints

- Production source is counted only from `.mbt` files, excluding tests, `.mbti`, `_build`, caches, and generated artifacts.
- The production target is 7,200–7,600 lines; every added line belongs to snapshot, policy, governance, migration, reporting, CLI, benchmark, or reusable support logic.
- The CLI must describe preview/sample behavior honestly and must not claim JSON file decoding that is not implemented.
- All deterministic outputs use stable ordering and JSON escaping for quotes, backslashes, and newlines.
- No Kafka network client, HTTP service, GitHub Bot, or unverified third-party dependency is added in this phase.
- Tests cover wasm, wasm-gc, and js locally; native remains covered by the existing Ubuntu CI job.
- Keep public concrete types in the root public package or the existing public `lib/types` package; keep helpers private in their owning `.mbt` file.
- Use TDD: each task writes failing tests, observes the expected failure, implements the smallest behavior, then runs focused and full tests.

---

### Task 1: Add immutable Schema snapshots and version-chain analysis

**Files:**
- Create: `lib/governance_snapshot_types.mbt`
- Create: `lib/governance_snapshot_store.mbt`
- Create: `lib/governance_snapshot_test.mbt`
- Modify: `lib/pkg.generated.mbti` via `moon info` only

**Interfaces:**
- Consumes: existing root `Schema`, `@types.SemVer`, and `SchemaRegistry` conventions.
- Produces:
  - `SnapshotStatus`, `SchemaSnapshot`, `SnapshotChainIssue`, `SnapshotChainReport`.
  - `SnapshotStore::new() -> SnapshotStore`.
  - `SnapshotStore::insert(self, snapshot : SchemaSnapshot) -> Result[Unit, String]`.
  - `SnapshotStore::get(self, subject : String, version : String) -> SchemaSnapshot?`.
  - `SnapshotStore::latest(self, subject : String) -> SchemaSnapshot?`.
  - `SnapshotStore::list(self, subject : String) -> Array[SchemaSnapshot]`.
  - `analyze_snapshot_chain(snapshots : Array[SchemaSnapshot]) -> SnapshotChainReport`.

- [ ] **Step 1: Write failing snapshot tests**

Add tests for empty lookup, first insert, duplicate subject/version rejection, invalid SemVer rejection, deterministic version ordering, latest selection, branch detection, and a valid three-version chain. The tests must construct real `Schema` values with `Schema::new` and assert exact issue codes.

```moonbit
test "snapshot store rejects duplicate versions and returns latest" {
  let store = SnapshotStore::new()
  let s1 = SchemaSnapshot::new("orders", Schema::new("orders", "Orders", "1.0.0", "fixture", []), source="fixture")
  let s2 = SchemaSnapshot::new("orders", Schema::new("orders", "Orders", "1.1.0", "fixture", []), source="fixture")
  assert_true(store.insert(s1).is_ok())
  assert_true(store.insert(s2).is_ok())
  assert_true(store.insert(s2).is_err())
  assert_eq(store.latest("orders").map(fn(x) { x.schema.version }), Some("1.1.0"))
}
```

- [ ] **Step 2: Run the focused test and verify failure**

Run: `moon test`  
Expected: FAIL because snapshot types and store functions do not exist.

- [ ] **Step 3: Implement the snapshot model and store**

Use `Map[String, Array[SchemaSnapshot]]`, validate `@types.SemVer::parse(snapshot.schema.version)`, reject duplicate versions, and return copies sorted by `SemVer::compare`. Store the supplied `source` and deterministic `created_at` string; never generate wall-clock values inside the library.

- [ ] **Step 4: Implement chain analysis and run focused tests**

Detect empty chains, invalid versions, duplicate versions, version gaps, and non-monotonic/branch-like input. Run `moon fmt`, `moon test`, and `moon check --deny-warn`.

- [ ] **Step 5: Commit the independently testable snapshot capability**

```powershell
git add lib/governance_snapshot_types.mbt lib/governance_snapshot_store.mbt lib/governance_snapshot_test.mbt lib/pkg.generated.mbti
git commit -m "feat: add deterministic schema snapshot governance"
```

### Task 2: Add policy rules, findings, and bounded exceptions

**Files:**
- Create: `lib/governance_policy_types.mbt`
- Create: `lib/governance_policy_engine.mbt`
- Create: `lib/governance_policy_test.mbt`
- Modify: `lib/pkg.generated.mbti` via `moon info` only

**Interfaces:**
- Consumes: `SnapshotChainReport`, existing `DiffEntry`, `ImpactLevel`, `CompatibilityLevel`, and `check_compatibility`.
- Produces:
  - `PolicyRuleKind`, `PolicySeverity`, `PolicyDecision`, `PolicyException`.
  - `GovernancePolicy::strict() -> GovernancePolicy` and `GovernancePolicy::permissive() -> GovernancePolicy`.
  - `PolicyFinding` with rule ID, field, severity, blocking flag, evidence, and exception status.
  - `evaluate_policy(policy : GovernancePolicy, base : Schema, target : Schema, level : CompatibilityLevel) -> Array[PolicyFinding]`.
  - `policy_decision(findings : Array[PolicyFinding]) -> PolicyDecision`.

- [ ] **Step 1: Write failing policy tests**

Cover optional field addition, required field addition, field removal, type narrowing/widening, constraint tightening, strict-vs-permissive policies, risk thresholds, exact exception matching, unrelated exception rejection, and deterministic finding order.

- [ ] **Step 2: Run `moon test` and confirm missing policy APIs fail**

Expected: compile failures naming the missing policy types and functions.

- [ ] **Step 3: Implement policy types and built-in policies**

Represent policy rules as explicit enums and arrays rather than dynamic maps. Give each finding a stable rule ID such as `required-field-added` or `type-narrowed`; make `PolicyException` match only the declared subject/field/rule triple.

- [ ] **Step 4: Implement evaluation and decision aggregation**

Evaluate existing compatibility results plus change-kind-specific rules. Apply exceptions only after producing the original evidence, and preserve both `was_blocking` and `exception_applied` in the finding. Sort findings by field name, rule ID, then severity.

- [ ] **Step 5: Run focused tests, format, and commit**

Run: `moon fmt`, `moon check --deny-warn`, `moon test`.  
Commit: `git add lib/governance_policy_* lib/pkg.generated.mbti; git commit -m "feat: add configurable contract governance policies"`.

### Task 3: Generate migration plans and rollback checks

**Files:**
- Create: `lib/migration_plan_types.mbt`
- Create: `lib/migration_planner.mbt`
- Create: `lib/migration_plan_test.mbt`
- Modify: `lib/pkg.generated.mbti` via `moon info` only

**Interfaces:**
- Consumes: `Schema`, `DiffEntry`, `ChangeKind`, `ImpactLevel`, and policy findings.
- Produces:
  - `MigrationActionKind`, `MigrationSafety`, `MigrationAction`, `MigrationPlan`.
  - `plan_schema_migration(base : Schema, target : Schema) -> MigrationPlan`.
  - `MigrationPlan::automatic_action_count() -> Int`.
  - `MigrationPlan::manual_action_count() -> Int`.
  - `MigrationPlan::is_reversible() -> Bool`.
  - `check_rollback(plan : MigrationPlan) -> Array[String]`.

- [ ] **Step 1: Write failing migration tests**

Assert action classification for optional addition, required addition without default, field removal, rename-like remove/add, type widening, type narrowing, constraint changes, nested changes, conflicting actions, and rollback failures.

- [ ] **Step 2: Run the focused test and observe the missing API failures**

Run: `moon test`. Expected: failures for migration types and planner functions.

- [ ] **Step 3: Implement action classification from real Diff entries**

Map each existing `ChangeKind` to a stable action. Mark safe optional additions and widening as automatic where no policy finding blocks them; mark required additions, removals, narrowing, and ambiguous changes as manual or unsafe. Never mutate either input Schema.

- [ ] **Step 4: Implement deterministic plan ordering and rollback checks**

Order actions by field name and action kind. A plan is reversible only when every action has a reverse operation and no required data is discarded. Return explicit rollback issue codes instead of a Boolean-only result.

- [ ] **Step 5: Run tests and commit**

Run: `moon fmt`, `moon check --deny-warn`, `moon test`.  
Commit: `git add lib/migration_plan_* lib/pkg.generated.mbti; git commit -m "feat: generate schema migration plans"`.

### Task 4: Compose governance decisions across a snapshot chain

**Files:**
- Create: `lib/governance_types.mbt`
- Create: `lib/governance_engine.mbt`
- Create: `lib/governance_test.mbt`
- Modify: `lib/pkg.generated.mbti` via `moon info` only

**Interfaces:**
- Consumes: `SnapshotStore`, `SnapshotChainReport`, `GovernancePolicy`, `PolicyFinding`, and `MigrationPlan`.
- Produces:
  - `GovernanceDecision`, `GovernanceStatus`, `GovernanceMetrics`, `GovernanceResult`.
  - `govern_subject(store : SnapshotStore, subject : String, policy : GovernancePolicy, level : CompatibilityLevel) -> GovernanceResult`.
  - `GovernanceResult::is_release_allowed() -> Bool`.
  - `GovernanceResult::risk_score() -> Int`.
  - `GovernanceResult::blocking_findings() -> Array[PolicyFinding]`.

- [ ] **Step 1: Write failing composition tests**

Cover an empty subject, a valid compatible chain, a chain with one blocked transition, multiple independent subjects, exception-resolved findings, and equal-input repeated runs. Assert status, transition count, risk score, migration counts, and stable ordering.

- [ ] **Step 2: Verify the focused tests fail**

Run: `moon test`. Expected: missing governance result and orchestration APIs.

- [ ] **Step 3: Implement transition-by-transition governance**

Load the sorted chain, analyze structural issues, compare adjacent schemas with `check_compatibility`, evaluate policy, generate a migration plan, and aggregate findings. Structural chain errors always block release; policy exceptions may lower a finding but never erase its evidence.

- [ ] **Step 4: Implement risk and status aggregation**

Use a documented additive score: structural error 20, blocking policy finding 10, manual migration 5, warning 2, capped at 100. Status is `Ready`, `NeedsApproval`, or `Blocked` based on findings and policy thresholds.

- [ ] **Step 5: Run tests and commit**

Run: `moon fmt`, `moon info`, `moon check --deny-warn`, `moon test`.  
Commit: `git add lib/governance_* lib/pkg.generated.mbti; git commit -m "feat: add release governance decisions"`.

### Task 5: Add deterministic governance reports

**Files:**
- Create: `lib/governance_report.mbt`
- Create: `lib/governance_report_test.mbt`
- Create: `lib/json_escape.mbt`
- Modify: `lib/pkg.generated.mbti` via `moon info` only

**Interfaces:**
- Consumes: `GovernanceResult`, `SnapshotChainReport`, `PolicyFinding`, and `MigrationPlan`.
- Produces:
  - `GovernanceResult::to_markdown() -> String`.
  - `GovernanceResult::to_json() -> String`.
  - `GovernanceResult::to_junit() -> String`.
  - `json_escape(value : String) -> String` for safe machine-readable output.

- [ ] **Step 1: Write failing report tests**

Assert headings, status, finding counts, migration counts, stable repeated output, valid escaping for quotes/backslashes/newlines, empty-result output, and JUnit failure/warning mapping.

- [ ] **Step 2: Run focused tests and confirm missing report APIs fail**

Run: `moon test`. Expected: missing methods and escaping helper.

- [ ] **Step 3: Implement shared JSON escaping**

Escape `\\`, `\"`, `\n`, `\r`, and `\t` in a single reusable helper. Keep report field order fixed and avoid Map iteration in serialization.

- [ ] **Step 4: Implement Markdown, JSON, and JUnit renderers**

Render all findings and actions, including evidence and exception state. JUnit must produce one testcase per blocking/warning finding with deterministic names and escaped text.

- [ ] **Step 5: Run report tests and commit**

Run: `moon fmt`, `moon check --deny-warn`, `moon test`.  
Commit: `git add lib/governance_report.mbt lib/governance_report_test.mbt lib/json_escape.mbt lib/pkg.generated.mbti; git commit -m "feat: add governance report formats"`.

### Task 6: Integrate CLI, benchmark workloads, and acceptance checks

**Files:**
- Modify: `lib/benchmark_types.mbt`
- Modify: `lib/benchmark_fixtures.mbt`
- Modify: `lib/benchmark_execution.mbt`
- Modify: `lib/benchmark_runner.mbt`
- Modify: `lib/benchmark_test.mbt`
- Modify: `lib/cli/args.mbt`
- Modify: `lib/cli/commands.mbt`
- Modify: `lib/cli/cli_test.mbt`
- Modify: `scripts/benchmark.ps1`
- Modify: `scripts/verify_acceptance.ps1`
- Modify: `lib/pkg.generated.mbti` and `lib/cli/pkg.generated.mbti` via `moon info` only

**Interfaces:**
- Consumes: `SnapshotStore`, `GovernancePolicy`, `govern_subject`, and report methods.
- Produces: four deterministic governance benchmark workloads and CLI commands `govern`, `snapshot`, `plan`, and `policy`.

- [ ] **Step 1: Write failing benchmark and CLI tests**

Assert the new operation enum cases, workload names and operation totals, governance report rendering, argument parsing, help text, and CLI sample output. Keep existing benchmark names and commands unchanged.

- [ ] **Step 2: Run focused tests and observe failures**

Run: `moon test`. Expected: missing enum cases, workloads, and command cases.

- [ ] **Step 3: Add standard governance fixtures**

Create a deterministic four-version order-contract chain containing an optional addition, required-field breaking change, type widening, and policy exception. Add workloads for chain scan, policy evaluation, migration planning, and report rendering with fixed iteration counts.

- [ ] **Step 4: Extend benchmark execution and renderers**

Execute the real snapshot/policy/migration/governance functions, record operation counts and monotonic elapsed time, and include the new workloads in Markdown and JSON output. Do not benchmark placeholder strings.

- [ ] **Step 5: Extend CLI and acceptance script**

Route `govern`, `snapshot`, `plan`, and `policy` through the standard fixtures and include output assertions in `cli_test.mbt`. Update `verify_acceptance.ps1` to require governance files, the new commands, the expanded benchmark, and production source between 7,200 and 7,600 lines.

- [ ] **Step 6: Run the integrated checks and commit**

Run: `moon fmt`, `moon info`, `moon check --deny-warn`, `moon test --deny-warn`, `powershell -ExecutionPolicy Bypass -File scripts/verify_acceptance.ps1`, and `powershell -ExecutionPolicy Bypass -File scripts/benchmark.ps1 -Runs 5`.  
Commit: `git add lib scripts benchmarks lib/pkg.generated.mbti lib/cli/pkg.generated.mbti; git commit -m "feat: integrate governance CLI and benchmarks"`.

### Task 7: Update documentation, package version, and final release evidence

**Files:**
- Modify: `README.md`
- Modify: `OSC2026_Hackathon_Proposal.md`
- Modify: `benchmarks/README.md`
- Modify: `benchmarks/latest.md` via benchmark script
- Modify: `moon.mod` version from `0.1.0` to `0.2.0`
- Modify: `task_plan.md`, `findings.md`, and `progress.md`
- Modify: `.github/workflows/publish.yml` expected-version documentation if needed

**Interfaces:**
- Consumes: final acceptance counts, benchmark evidence, CLI examples, and generated public interfaces.
- Produces: consistent 7,200–7,600 source metrics, updated hackathon application narrative, and publishable Mooncakes version `0.2.0`.

- [ ] **Step 1: Update docs from measured output**

Run the acceptance script and use its exact production/test/total values in README and the proposal. Document the new governance workflow, boundaries, commands, report formats, benchmark workloads, and Windows portable-target limitation without claiming unsupported file decoding.

- [ ] **Step 2: Update package version and generated interfaces**

Set `moon.mod` to `version = "0.2.0"`, run `moon update`, `moon info`, and `moon fmt`, then inspect all `.mbti` diffs for intentional public API additions only.

- [ ] **Step 3: Run the complete local verification matrix**

Run `moon fmt --check`, `moon check --deny-warn --target all`, `moon test --deny-warn` for wasm/wasm-gc/js, the acceptance script, the benchmark script, `moon run cmd/main -- govern`, `moon run cmd/main -- plan`, `git diff --check`, and `git status --short --branch`. Record native limitations explicitly if the local MinGW toolchain still lacks `rand_s`.

- [ ] **Step 4: Run package dry-run and review the final diff**

Run `moon whoami`, `moon publish --dry-run`, inspect `git diff --stat`, review public interfaces, and run a read-only code review focused on deterministic ordering, policy exceptions, migration correctness, report escaping, source-count honesty, and version consistency.

- [ ] **Step 5: Commit, push, and publish version 0.2.0**

After all checks pass, verify `gh repo view lyjttio/moon-data-contract --json nameWithOwner,defaultBranchRef,owner`, confirm owner `lyjttio` and branch `main`, then commit and push. Verify the remote ref and run `moon publish`; record the `200 OK` result without storing credentials.

## Plan self-review

- Spec coverage: snapshot/version chains are Task 1; policy and exceptions Task 2; migration and rollback Task 3; release decisions Task 4; Markdown/JSON/JUnit Task 5; CLI/benchmark Task 6; metrics, package version, CI, and publication Task 7.
- Scope: all tasks remain offline and within the existing root package; Kafka, Bot, and network services are explicitly excluded.
- Type consistency: later tasks consume `SchemaSnapshot`, `SnapshotStore`, `GovernancePolicy`, `PolicyFinding`, `MigrationPlan`, and `GovernanceResult` exactly as produced by earlier tasks.
- Placeholder scan: no reserved-marker or unspecified implementation step remains; each task has concrete files, interfaces, tests, commands, and expected verification.
