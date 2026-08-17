# moon-data-contract 8 月黑客松结项设计

## 背景与目标

当前仓库已有完整的数据契约核心链路，但排除测试后的生产 MoonBit 源码为 3,277 行。结项目标不是用注释或重复代码增加行数，而是在现有 Schema、Payload、Diff、Compatibility、Registry、Generator 和 Report 能力上补齐可复用的审计与基准工作流，使项目具备真实的工程验收证据：生产 `.mbt` 行数达到 4,000 以上，核心边界测试扩展，benchmark 可复现并记录实际执行结果，CI 和 Mooncakes 发布路径完整。

赛事定位统一为 2026 年 8 月 MoonBit 黑客松。OSC2026 只作为外部自查资料名称，不出现在项目参赛归属描述中。

## 方案

新增两个相互独立但共享现有核心 API 的能力：

1. **Benchmark**：在根 `lib` 包提供确定性样本构造、批量校验、Schema Diff、兼容性和导出工作负载。使用已验证的 `moonbitlang/core/bench` 单调时钟测量微秒级耗时，输出结构化结果和 Markdown 报告。样本包含小型、宽 Schema、深层嵌套和混合有效/无效 Payload，所有数据由代码确定性生成。
2. **Audit**：把一次契约验收需要的检查统一成结构化结果，覆盖字段重复、字段数、Payload 校验、Schema Diff、兼容级别、推荐版本升级和导出产物完整性，并能输出严重级别、稳定代码和人类可读报告。

CLI 使用 `moonbitlang/core/env.args()` 读取参数，接入已有命令解析器，保留现有 validate/diff/check/export/version/help 命令，并增加 `benchmark` 和 `audit` 演示入口。没有文件 I/O 依赖时，CLI 使用内置确定性样本；已有库 API 继续支持调用方传入自己的 Schema 和 Payload。

## 测试策略

- 新增 API 先写黑盒失败测试，再实现最小行为。
- Benchmark 测试验证样本规模、有效/无效计数、非负耗时、总计聚合和 Markdown/JSON 稳定字段。
- Audit 测试覆盖空 Schema、重复字段、必填字段缺失、类型变化、可选字段增加、兼容性失败、导出目标未知和报告摘要。
- 额外边界覆盖：空/单字段/宽字段 Schema、深层嵌套 Payload、Unicode 字段和值、约束上下界、非法 SemVer、循环依赖、LRU 容量边界和大批量迭代。
- CI 运行 `moon check --target all`、`moon test --target all`，Windows/macOS/Linux 矩阵下统一验证。

## 指标与证据

源码规模统计脚本只统计版本控制范围内、排除 `_build` 的 `.mbt` 文件，并分别报告 production/test/total 行数。Benchmark 报告记录日期、工具链版本、目标后端、样本规模、迭代次数、每个工作负载实测微秒和聚合吞吐；不把预估值写成实测值。

## CI 与发布

- CI 按 `moonbit-community/.github` 模板改造：稳定安装脚本、`moon version --all`、`moon update`、三平台、全目标 check/test、`moon fmt` 后 git diff、`moon info` 后 git diff，并补充 native build/coverage 证据。
- 新增手动触发的发布 workflow：先 check/test，再使用 GitHub Secret 写入 Mooncakes 凭据，执行 `moon publish`，最后删除凭据。
- 发布前检查 `moon.mod` 模块名、GitHub 当前授权账号、远程默认分支、唯一贡献者和 Mooncakes 登录账号；任何身份不匹配都停止发布。

## 非目标

本次不实现 Kafka 网络协议、GitHub Bot 服务或外部 Schema Registry 服务端。这些属于申报书未来方向，当前以可复用的审计、基准、报告和 CI 门禁提供可落地的基础能力，避免引入未经验证的网络依赖和平台特定代码。
