# moon-data-contract

[![MoonBit CI](https://github.com/lyjttio/moon-data-contract/actions/workflows/ci.yml/badge.svg)](https://github.com/lyjttio/moon-data-contract/actions/workflows/ci.yml)
[![Mooncakes](https://img.shields.io/badge/Mooncakes-0.2.1-6f42c1.svg)](https://mooncakes.io/)
[![License](https://img.shields.io/badge/License-Apache--2.0-blue.svg)](LICENSE)
[![MoonBit](https://img.shields.io/badge/MoonBit-stable-purple.svg)](https://www.moonbitlang.com/)

**Deterministic schema governance for MoonBit.** Model contracts, validate payloads, audit schema evolution, plan migrations, and enforce release gates in offline-first workflows.

`moon-data-contract` 是一个纯 MoonBit 数据契约与 Schema 演化工具，面向微服务、数据管道和事件驱动系统。它把“字段改了会不会影响消费者”从人工检查变成可重复、可审计、可接入 CI 的工程流程。

本项目参加的是 **2026 年 8 月黑客松**，由 `lyjttio` 独立开发，采用 [Apache License 2.0](LICENSE)。

## Why this package

数据契约通常同时承担三件事：描述数据、约束运行时 Payload、保护版本演化。这个包提供一条离线且确定性的治理链：

```text
Contract model → Payload validation → Schema diff → Compatibility audit
      → Migration plan → Policy gate → Markdown / JSON / JUnit evidence
```

适合希望在 MoonBit 服务、数据管道或事件系统中建立 Schema 门禁的团队。核心库不依赖网络服务、数据库或运行时反射，便于在 wasm、wasm-gc、js 和 native 目标中复用。

## Capabilities

| Area | What is included |
| --- | --- |
| Contract model | Bool、Int、Double、String、Enum、Array、Optional、Struct，以及主键、默认值和字段约束 |
| Runtime validation | 必填字段、主键、数值范围、字符串规则、枚举、严格校验和类型强制转换 |
| Schema evolution | AST Diff、破坏性变更识别、Backward/Forward/Full 兼容性、传递兼容性和版本矩阵 |
| Registry and generation | Registry、缓存、文件存储、依赖 DAG，以及 SQL、Proto、TypeScript、Avro、Graphviz、GraphQL、Parquet 和 Mock 导出 |
| Governance | 快照链、完整性校验、策略例外、风险分级、迁移/回滚计划、审批台账、发布检查清单和治理 replay |
| Evidence | Markdown、JSON、JUnit 和 HTML 报告，适合 CI artifact、代码评审和验收留档 |

## Install

```bash
moon add lyjttio/moon-data-contract@0.2.1
```

包的默认推荐目标是 `wasm-gc`；发布版本遵循 Mooncakes 的语义化版本递增规则。

## 30-second API example

核心 API 直接以 MoonBit 类型表达契约，并可对两个版本执行确定性的 Diff：

```moonbit
import {
  "lyjttio/moon-data-contract/lib" as @contract,
}

let v1 = @contract.Schema::new(
  "orders",
  "Order",
  "1.0.0",
  "commerce",
  [
    @contract.Field::new(
      "order_id",
      @contract.DataType::Primitive(@contract.PrimitiveType::TString),
      primary_key=true,
    ),
  ],
)
let v2 = @contract.Schema::new(
  "orders",
  "Order",
  "1.1.0",
  "commerce",
  [
    @contract.Field::new(
      "order_id",
      @contract.DataType::Primitive(@contract.PrimitiveType::TString),
      primary_key=true,
    ),
    @contract.Field::new(
      "currency",
      @contract.DataType::Primitive(@contract.PrimitiveType::TString),
      required=false,
    ),
  ],
)

let changes = @contract.diff_schemas(v1, v2)
```

在需要完整治理时，可以把版本快照放入 `SnapshotStore`，再用 `govern_subject` 生成策略决策、迁移计划和报告：

```moonbit
let result = @contract.govern_subject(
  store,
  "orders",
  @contract.GovernancePolicy::strict(),
  @contract.CompatibilityLevel::Backward,
)
let markdown = result.to_markdown()
```

## CLI and evidence

仓库包含可复现的离线 CLI 示例：

```powershell
moon run cmd/main -- benchmark
moon run cmd/main -- audit
moon run cmd/main -- govern
moon run cmd/main -- snapshot
moon run cmd/main -- plan
moon run cmd/main -- policy
```

`benchmark`、`audit`、`govern`、`snapshot`、`plan` 和 `policy` 输出可直接用于验收或 CI artifact；`validate`、`diff`、`check`、`export` 提供参数解析和预览入口。当前便携 CLI **尚未解码 JSON 文件**，生产集成应直接调用库 API，而不是把 CLI 预览当成文件服务。

## Verified quality

以下数字来自当前仓库的验收脚本、MoonBit 测试和 benchmark 证据，不是估算：

| Measure | Verified value |
| --- | ---: |
| 有效生产 MoonBit 源码 | **7,020 行** |
| 物理生产 MoonBit 源码 | **7,560 行** |
| 测试源码 | **1,971 行 / 62 个测试文件** |
| MoonBit 源码总量 | **9,531 行** |
| 测试结果 | **104/104 通过** |
| Benchmark operations | **792 次契约操作/次** |
| Governance workloads | **4 类**，总计 8 类 workload |

有效生产源码口径排除了空行、注释、测试、`.mbti`、缓存和构建产物；物理生产行用于补充规模信息。Benchmark 在本机 Windows、`wasm-gc` 目标上运行 5 次 wall-clock 样本，核心计时和样本见 [`benchmarks/latest.md`](benchmarks/latest.md)，仅代表当前机器的可复现实测，不构成跨机器性能承诺。

刷新 benchmark：

```powershell
powershell -ExecutionPolicy Bypass -File scripts/benchmark.ps1 -Runs 5
```

## Development

```powershell
moon fmt --check
moon info
moon check --deny-warn --target all
moon test --deny-warn --target all
```

验收自查：

```powershell
powershell -ExecutionPolicy Bypass -File scripts/verify_acceptance.ps1
```

CI 在 Ubuntu、macOS 和 Windows 上使用最新 stable MoonBit 工具链；Unix runner 执行全目标 check/test，Windows 执行 wasm、wasm-gc、js 可移植目标，另有 Ubuntu native build/test 门禁。发布 workflow 仅支持手工触发，先完成门禁，再使用 GitHub Secret `MOONCAKES_TOKEN` 发布。

## Repository map

```text
moon-data-contract/
├── moon.mod
├── LICENSE
├── README.md
├── OSC2026_Hackathon_Proposal.md
├── benchmarks/              # reproducible benchmark evidence
├── scripts/                 # benchmark and acceptance checks
├── .github/workflows/       # CI and manual Mooncakes release
├── lib/                     # core library and 62 test files
└── cmd/main/                # offline CLI entry point
```

边界测试覆盖空 Schema、重复字段、缺失必填字段、类型变化、可选字段增加、嵌套 Struct、Unicode 字段、约束上下界、非法版本、快照重复/跳跃/撤销、策略例外、迁移回滚、审批台账、风险边界、循环依赖、宽 Schema 和混合有效/无效 Payload。测试使用真实核心实现，不用 mock 替代校验或 Diff 逻辑。

## License and contribution

本项目采用 [Apache License 2.0](LICENSE)。当前仓库提交历史的作者和唯一贡献者为 `lyjttio`。贡献方式和安全问题处理见 [`CONTRIBUTING.md`](CONTRIBUTING.md) 与 [`SECURITY.md`](SECURITY.md)。
