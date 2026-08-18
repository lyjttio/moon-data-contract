# MoonBit 2026 年 8月黑客松项目申报书

| 项目 | 内容 |
| --- | --- |
| 项目名称 | MoonBit 数据契约与 Schema 演化工具 (`moon-data-contract`) |
| 参赛赛事 | 2026 年 8月 MoonBit 黑客松 |
| 独立开发者 | `lyjttio` |
| GitHub | https://github.com/lyjttio/moon-data-contract |
| 许可证 | Apache License 2.0 |

## 项目背景

分布式服务、事件消息和数据仓库之间依赖稳定的数据契约。字段删除、类型缩窄、必填项增加或约束收紧，都可能让下游服务在运行时崩溃。MoonBit 生态缺少一套纯 MoonBit、可嵌入库、可用于 CI 的 Schema 演化基础设施。本项目提供从契约建模到运行时校验、版本演化和报告生成的完整链路。

## 已完成的基础与黑客松交付

- 类型系统支持 Bool、Int、Double、String、Enum、Array、Optional 和 Struct。
- Payload 校验支持必填、主键、范围、枚举、字符串规则、严格模式和类型强制转换。
- AST Diff、破坏性变更识别、BACKWARD/FORWARD/FULL 兼容性和迁移矩阵已实现。
- Schema Registry、缓存、文件存储、依赖 DAG 和 SQL/Proto/TypeScript/Avro/Graphviz/Mock 导出已实现。
- 新增 Contract Audit、嵌套 Schema Profile、确定性 benchmark 和 `benchmark`/`audit` CLI。
- 新增离线治理流水线：Schema 快照链、完整性校验、策略档案/矩阵、迁移与回滚计划、审批台账、风险分级、发布检查清单、治理 trace、发布建议，以及 `govern`/`snapshot`/`plan`/`policy` CLI。
- 新增空 Schema、重复字段、Unicode、深层嵌套、约束极值、非法版本、缓存和循环依赖边界测试。

## 技术路线

核心实现全部使用 MoonBit，保持包边界清晰：`lib/types` 管理模型，根 `lib` 提供校验/Diff/兼容性/治理/审计/benchmark，`lib/registry` 管理注册与依赖，`lib/generators` 和 `lib/report` 面向集成输出，`cmd/main` 提供 CLI。治理流水线完全离线，使用显式快照、策略、迁移计划、审批和报告类型组合发布门禁，不伪装成 Kafka/HTTP 服务。Benchmark 使用 MoonBit stable 的单调时钟，固定生成小型、24 字段宽 Schema、兼容演化、版本链扫描、策略评估、迁移规划和治理报告八类工作负载；PowerShell 脚本补充不同运行的 wall-clock 证据。

## 工程指标

当前实测有效生产 MoonBit 源码 7,020 行、物理生产行 7,560 行、测试源码 1,971 行、总量 9,531 行；测试 104/104 通过，测试文件 62 个。CI 覆盖 Ubuntu、macOS 的全目标 check/test、Windows 的 wasm/wasm-gc/js 可移植目标，以及 Ubuntu native build/test；验收脚本检查有效源码口径、文档、许可证、CI 标记、治理 CLI 和核心 MoonBit 命令。实测 benchmark 保存在 `benchmarks/latest.md`，并记录工具链、目标后端、792 次操作、治理 workload、样本规模和运行结果。

## 应用价值与后续方向

项目可作为服务间 Schema 门禁库、事件契约审核工具、迁移排演工具和代码生成基础设施，减少数据生产方与消费方之间的隐式破坏性变更。治理报告、JUnit 输出、审批台账和 trace 可直接作为 CI 制品；后续可在现有审计和报告 API 上接入 Kafka Schema Registry 协议、GitHub Pull Request 门禁 Bot，以及更多数据格式适配器；本次黑客松不引入未经验证的网络服务依赖。
