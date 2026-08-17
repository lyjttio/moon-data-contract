# MoonBit 8 月黑客松结项计划

## 2026-08-18 扩展目标

在已完成 4,063 行生产源码的基础上，按申报书方向实现离线数据契约治理流水线，目标生产源码 7,200–7,600 行。具体范围、接口边界、测试策略和发布约束见 [`docs/superpowers/specs/2026-08-18-contract-governance-expansion-design.md`](docs/superpowers/specs/2026-08-18-contract-governance-expansion-design.md)。实施计划见 [`docs/superpowers/plans/2026-08-18-contract-governance-expansion.md`](docs/superpowers/plans/2026-08-18-contract-governance-expansion.md)。

当前执行状态：Task 1 Snapshot、Task 2 Policy 已完成；Task 3 Migration 待开始。

## 目标

把 `moon-data-contract` 完成到可验收、可复现、可发布的结项状态：以有实际应用价值的功能把有效生产 MoonBit 源码提升到至少 4,000 行，补齐真实基准数据与边界测试，按最新 stable MoonBit 工具链完善 CI，修正文档赛事定位，完成 GitHub 默认分支/唯一贡献者/远程账号核验，并通过 Mooncakes 发布流程。

## 阶段

1. **现状审计与设计确认** — complete
   - 读取申报书、README、MoonBit 配置、工作流、提交历史和远程信息。
   - 对照 `osc2026-guide`、赛事说明、社区 workflow 模板和参考 CI。
   - 明确新增功能、指标口径、发布边界。
2. **核心能力扩展与测试先行** — complete
   - 在现有数据契约核心边界内增加可复用的基准/审计能力。
   - 先写失败测试，再实现功能；补齐空值、深嵌套、循环依赖、版本边界和大输入测试。
3. **基准数据与可复现实验** — complete
   - 生成并提交可复现的真实基准结果，说明硬件、工具链、命令和样本规模。
   - README/申报书改为实测指标，区分生产源码、测试源码和总源码。
4. **CI、文档与发布准备** — complete
   - 升级到最新 stable 安装流程；加入 check/test/build/format/info/coverage 等必要门禁。
   - 检查根目录结构、许可证、默认分支、贡献者、敏感信息和 Mooncakes 元数据。
5. **最终验证、审查与推送** — complete
    - 运行完整本地命令并检查 diff/mbti/规模。
    - 请求只读代码审查，修复重要问题；已修正 benchmark 文档、native 测试门禁和发布分支/版本保护。
    - 核验 GitHub 仓库 owner/default branch、Mooncakes 登录身份后提交、推送、发布；GitHub API user endpoint 曾短暂 503，但仓库 owner 查询已确认 `lyjttio`。

## 成功标准

- 生产 `.mbt` 行数 >= 4,000，且新增代码属于可复用功能而非注释/填充。
- `moon check --deny-warn`、`moon test --deny-warn`、格式化检查、`moon info` 和至少一个稳定后端构建通过。
- CI 使用稳定版安装脚本并覆盖 Linux/macOS/Windows，执行 target-all 检查和测试。
- README、申报书与实际命令输出一致，包含可运行示例、真实 benchmark 数据、边界测试说明和 Mooncakes 发布信息。
- GitHub 远程为 `lyjttio/moon-data-contract`，默认分支与本地推送目标明确，贡献者仍只有账号创建者。
- Mooncakes 发布前完成 `moon publish --dry-run`，正式发布仅在身份核验无误后执行。

## 风险与约束

- 赛事是 8 月黑客松，不应继续把项目描述成 OSC 开源大赛参赛项目。
- 不能把 `_build` 产物或测试代码冒充生产源码规模。
- 不读取历史缓存账号；GitHub 与 Mooncakes 身份必须由当前授权命令直接核验。
- 远程推送属于外部状态变更，必须在本地验证和账号核验后进行。

## 错误记录

| 错误 | 尝试 | 处理 |
| --- | --- | --- |
| `gh auth status` 无法读取 GitHub CLI 配置，提示 Access is denied | 本地沙箱只读检查 | 暂不推送；最终阶段使用授权环境核验，必要时请求提升权限 |
| 直接打开两个赛事 URL 被网页工具判定为不安全 | 官方页面直开 | 改用可访问的官方/仓库原始文件与搜索结果；未把未验证页面内容当作事实 |
