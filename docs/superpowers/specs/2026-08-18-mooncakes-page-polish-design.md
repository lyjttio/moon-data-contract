# Mooncakes Package Page Polish Design

## Goal

把 `lyjttio/moon-data-contract` 的 Mooncakes 包首页从“验收材料汇总”整理为专业、可快速理解和安装的 MoonBit 数据治理工具包页面，并发布为 `0.2.1`。

## Audience and positioning

- 首要读者是准备在 MoonBit 项目中引入 Schema 校验和演化治理的开发者。
- 首屏采用英文产品定位，保留中文黑客松背景和项目说明。
- 所有能力、性能、源码规模和兼容性描述必须来自仓库当前实现与已验证记录，不增加未实现的 JSON 文件解码、网络服务或消息队列能力。

## Content design

README 按以下顺序组织：

1. 标题、CI/许可证/MoonBit/Mooncakes 徽章和一句话定位。
2. 30 秒理解：解决的问题、核心能力和适用场景。
3. 安装与最小 MoonBit API 示例，示例只使用仓库已有公开接口。
4. 能力矩阵：契约建模、运行时校验、演化审计、迁移治理、报告与 CI 门禁。
5. CLI 入口和输出物说明，明确当前 CLI 的离线预览边界。
6. 可验证质量证据：有效生产源码、测试规模、104/104 测试、8 类 benchmark workload、CI 平台和基准链接。
7. 目录、边界测试、发布方式、许可证与唯一贡献者说明。

## Metadata design

`moon.mod` 的版本提升为 `0.2.1`；描述改为面向使用者的英文一句话描述；关键词增加 `moonbit`、`governance`、`migration` 和 `ci`，保留现有技术关键词；仓库、许可证和首选目标不变。

## Validation and release

- README 中的指标与 `benchmarks/latest.md`、`scripts/verify_acceptance.ps1` 保持一致。
- 执行 `moon fmt --check`、`moon info`、`moon check --deny-warn --target all`、可移植目标测试和验收脚本。
- 仅使用直接身份核查：`moon whoami` 应为 `lyjttio`，GitHub 仓库所有者和默认分支应为 `lyjttio` / `main`。
- 推送 GitHub 后等待 CI 全部成功，再使用 `moon publish` 发布 `0.2.1`。

## Non-goals

- 不修改 MoonBit 核心 API、业务逻辑、测试规模或 benchmark 算法。
- 不添加未经验证的截图、虚构下载量、跨机器性能结论或外部服务集成。
- 不读取或切换历史缓存账号。
