# Mooncakes Package Page Polish Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task with verification checkpoints.

**Goal:** 将 `lyjttio/moon-data-contract` 的 Mooncakes 包首页整理为专业、可快速上手且完全基于真实实现证据的 `0.2.1` 发布页面。

**Architecture:** 只调整模块元数据和 README 展示层，不修改 MoonBit 核心 API、业务逻辑、测试与 benchmark 实现。README 采用英文产品定位 + 中文项目背景的双语入口，并按使用者阅读路径排列安装、能力、边界、质量证据和发布信息。

**Tech Stack:** MoonBit `moon.mod`、Markdown README、PowerShell 验收脚本、GitHub Actions、Mooncakes CLI。

## Global Constraints

- 发布版本从 `0.2.0` 顺序提升到 `0.2.1`。
- `moon whoami` 必须显示 `lyjttio`；GitHub 仓库所有者和默认分支必须是 `lyjttio` / `main`。
- 只能使用仓库已实现的 API、CLI 和已验证数字，不宣称 JSON 文件解码、网络服务或消息队列集成。
- README 指标必须与 `benchmarks/latest.md` 和 `scripts/verify_acceptance.ps1` 一致。
- 不改变有效生产 MoonBit 源码、测试数量或 benchmark workload。

---

### Task 1: Rewrite the package landing page

**Files:**
- Modify: `README.md`

**Interfaces:**
- Consumes: existing public API examples, CLI commands, `benchmarks/latest.md`, `scripts/verify_acceptance.ps1`, `CONTRIBUTING.md`, and `SECURITY.md`.
- Produces: Mooncakes-friendly README with product-first positioning, exact install command, verified API/CLI examples, capability matrix, boundaries, quality evidence, and release links.

- [ ] Preserve acceptance facts with `rg` before editing.
- [ ] Rewrite sections in this order: title/badges, English positioning, Chinese context, problem statement, capability matrix, installation, minimal existing API example, CLI preview commands, outputs, verified quality evidence, repository map, boundary tests, CI/release, license/contribution.
- [ ] Include `moon add lyjttio/moon-data-contract@0.2.1` and the verified values: 7,020 effective production lines, 7,560 physical production lines, 1,971 test lines across 62 test files, 9,531 total `.mbt` lines, 104/104 tests, and eight benchmark workloads with 792 contract operations per run.
- [ ] State that benchmark timing is machine-specific evidence and that the portable CLI does not decode JSON files.
- [ ] Run `git diff --check` and scan for stale `7,000`, `7,540`, or `0.2.0` README claims.
- [ ] Commit with `git add README.md; git commit -m "docs: polish Mooncakes package landing page"`.

### Task 2: Refresh module metadata for discovery

**Files:**
- Modify: `moon.mod`

**Interfaces:**
- Consumes: existing module identity, repository, license, preferred target, and package capabilities.
- Produces: version `0.2.1`, searchable MoonBit/governance keywords, and a concise package description.

- [ ] Set version to `0.2.1`.
- [ ] Set keywords to `moonbit`, `schema`, `data-contract`, `schema-evolution`, `governance`, `migration`, `validation`, and `ci`.
- [ ] Set description to `Deterministic schema governance for MoonBit: validate contracts, audit evolution, plan migrations, and enforce release gates.`
- [ ] Keep `name`, `readme`, `repository`, `license`, and `preferred_target = "wasm-gc"` unchanged.
- [ ] Run `moon fmt --check`, `moon info`, and `moon check --deny-warn --target all`.
- [ ] Commit with `git add moon.mod; git commit -m "chore: publish Mooncakes metadata 0.2.1"`.

### Task 3: Run release evidence and identity checks

**Files:**
- Verify: `README.md`, `moon.mod`, `benchmarks/latest.md`, `scripts/verify_acceptance.ps1`
- Do not modify: source, tests, or benchmark implementation

**Interfaces:**
- Consumes: the documentation and metadata commits from Tasks 1–2.
- Produces: local verification evidence and release authorization checks.

- [ ] Run `moon test --deny-warn --target wasm`, `moon test --deny-warn --target wasm-gc`, and `moon test --deny-warn --target js`; each must report `104/104`.
- [ ] Run `powershell -ExecutionPolicy Bypass -File scripts/verify_acceptance.ps1`; it must report the verified source metrics.
- [ ] Run `moon whoami`, `gh repo view lyjttio/moon-data-contract --json nameWithOwner,defaultBranchRef,owner,url`, and `git remote -v`.
- [ ] Confirm direct identities are `lyjttio` and `main`; do not inspect account lists or switch credentials.
- [ ] Run `git diff --check` and inspect any generated evidence diff before committing it.

### Task 4: Push, wait for CI, and publish Mooncakes

**Files:**
- Modify remotely: `origin/main` and Mooncakes package `lyjttio/moon-data-contract@0.2.1`

**Interfaces:**
- Consumes: clean local tree, successful checks, and direct identity checks.
- Produces: GitHub `main` containing the page polish and a published Mooncakes `0.2.1` package.

- [ ] Push with `git push origin main`.
- [ ] Use `gh run list --repo lyjttio/moon-data-contract --branch main --limit 5` to identify the newest run, then run `gh run watch --repo lyjttio/moon-data-contract --exit-status` for that newest run; Ubuntu, macOS, Windows, and native jobs must pass.
- [ ] Run `moon publish --dry-run`, then `moon publish`; the server must accept `0.2.1`.
- [ ] Re-run `moon whoami`, `gh repo view ...`, and `git status --short --branch`; owner/default branch must remain `lyjttio` / `main` and the tree must be clean.

## Self-review

- Scope is limited to package presentation and release metadata; no core implementation is changed.
- All acceptance-critical metrics and boundaries have explicit verification steps.
- No placeholder values or invented public APIs are included.
