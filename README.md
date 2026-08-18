# moon-data-contract

[![MoonBit CI](https://github.com/lyjttio/moon-data-contract/actions/workflows/ci.yml/badge.svg)](https://github.com/lyjttio/moon-data-contract/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/License-Apache--2.0-blue.svg)](LICENSE)
[![MoonBit](https://img.shields.io/badge/MoonBit-stable-purple.svg)](https://www.moonbitlang.com/)

`moon-data-contract` 是一个纯 MoonBit 数据契约与 Schema 演化工具，面向微服务、数据管道和事件驱动系统，提供契约建模、Payload 校验、兼容性审计、版本 Diff、注册表、代码生成、报告和 CI 门禁能力。

本项目参加的是 **2026 年 8 月黑客松**。项目由 `lyjttio` 独立开发，仓库使用 Apache License 2.0。

## 能力概览

- 类型系统：Bool、Int、Double、String、Enum、Array、Optional、Struct。
- 运行时校验：必填字段、主键、范围、枚举、字符串规则、严格校验和类型强制转换。
- Schema 演化：AST Diff、破坏性变更识别、兼容性等级、传递兼容性和迁移矩阵。
- 注册与生成：Schema Registry、缓存、文件存储、依赖 DAG、SQL/Proto/TypeScript/Avro/Graphviz/Mock 导出。
- 工程化审计：确定性 benchmark、结构化 Contract Audit、嵌套 Schema Profile、Markdown/JSON/JUnit/HTML 报告。
- 离线治理：Schema 快照链、完整性校验、策略档案与矩阵、迁移/回滚计划、审批台账、风险分级、发布检查清单、治理 trace 和可执行建议。
- CLI：`benchmark`、`audit`、`govern`、`snapshot`、`plan`、`policy` 可直接用于验收或 CI；`validate`、`diff`、`check`、`export` 提供参数解析和可审计的预览入口。便携 CLI 尚未解码 JSON 文件，生产集成应直接调用库 API。

## 目录结构

```text
moon-data-contract/
├── moon.mod
├── LICENSE
├── README.md
├── OSC2026_Hackathon_Proposal.md
├── benchmarks/
│   ├── README.md
│   └── latest.md
├── scripts/
│   ├── benchmark.ps1
│   └── verify_acceptance.ps1
├── .github/workflows/
│   ├── ci.yml
│   └── publish.yml
├── lib/                  # 核心库与 62 个测试
└── cmd/main/             # 可执行 CLI
```

## 规模与实测指标

以下数字由 `scripts/verify_acceptance.ps1` 和 `moon test` 实测生成，统计 `.mbt` 扩展名并排除 `_build`、缓存和生成目录：

- 有效生产 MoonBit 源码：**7,000 行**（验收脚本排除空行、注释、测试、`.mbti`、缓存和构建产物；物理生产行 7,540）。
- 测试 MoonBit 源码：**1,971 行**（62 个测试文件）。
- MoonBit 源码总量：**9,531 行**。
- 测试结果：**104/104 通过**。
- 本地工具链：`moon 0.1.20260807`，`moonc v0.10.7+bc794d341`，稳定编译器线 `0.10.7`。

Benchmark 结果见 [`benchmarks/latest.md`](benchmarks/latest.md)。当前证据记录本机 Windows、wasm-gc 目标、792 次契约操作/次、四类治理 workload 和 5 次 wall-clock 样本；MoonBit 核心计时为本机实测值，不是跨机器性能承诺。刷新命令：

```powershell
powershell -ExecutionPolicy Bypass -File scripts/benchmark.ps1 -Runs 5
```

## 快速开始

```powershell
moon check --deny-warn
moon test --deny-warn
moon run cmd/main -- benchmark
moon run cmd/main -- audit
moon run cmd/main -- govern
moon run cmd/main -- snapshot
moon run cmd/main -- plan
moon run cmd/main -- policy
```

全目标验证：

```powershell
moon check --deny-warn --target all
moon test --deny-warn --target all
moon build --target native
```

验收自查：

```powershell
powershell -ExecutionPolicy Bypass -File scripts/verify_acceptance.ps1
```

## 边界测试

测试覆盖空 Schema、重复字段、缺失必填字段、类型变化、可选字段增加、嵌套 Struct、Unicode 字段、约束上下界、非法版本、快照重复/跳跃/撤销、策略例外、迁移回滚、审批台账、风险边界、循环依赖、宽 Schema 和混合有效/无效 Payload。测试使用真实核心实现，不使用 mock 替代校验或 Diff 逻辑。

## CI 与发布

GitHub Actions 在 Ubuntu、macOS 和 Windows 上安装最新 stable MoonBit；Unix runner 执行 `moon check/test --target all`，Windows 执行 wasm、wasm-gc、js 三个可移植目标，另有 Ubuntu native build/test 门禁。所有平台都执行 `moon update`、格式化 diff 和 `moon info` 接口 diff。发布 workflow 仅支持手工触发，先完成 check/test，再使用 GitHub Secret `MOONCAKES_TOKEN` 发布到 Mooncakes，并在步骤结束后清理凭据。

## 许可证与贡献

本项目采用 [Apache License 2.0](LICENSE)。当前仓库提交历史的作者和唯一贡献者为 `lyjttio`。贡献与安全问题处理方式见 [`CONTRIBUTING.md`](CONTRIBUTING.md) 和 [`SECURITY.md`](SECURITY.md)。
