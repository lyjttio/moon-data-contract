# 结项审计发现

## 初始本地仓库审计

- 当前分支：`main`，跟踪 `origin/main`；结项变更和申报书已准备纳入本次提交。
- Git 远程：GitHub `https://github.com/lyjttio/moon-data-contract.git`；另有 GitLink `lyjtttio/moon-data-contract`。
- 最近提交身份全部为 `lyjttio <lyjttio@users.noreply.github.com>`；当前可见历史 19 次提交，粒度清晰。
- `moon.mod` 模块名为 `lyjttio/moon-data-contract`，许可证 Apache-2.0，默认 target `wasm-gc`。
- 根目录有 Apache-2.0 `LICENSE`、README、申报书、`.github/workflows/ci.yml` 和 `copilot-setup-steps.yml`。
- `.gitignore` 已忽略 `_build/`、`target/`、`.mooncakes/`、`.moonagent/`；工作区中的 `_build/` 是既有本地产物，未进入 git。

## 初始规模基线

- 排除 `_build` 后 `.mbt` 共 91 个文件、4,121 行。
- 生产文件 53 个、3,277 行；测试文件 38 个、844 行。
- 因此 README/申报书的 4,023 行没有明确口径，且不能满足“有效生产源码 4,000+”的更严格验收解释；需要新增真实生产能力并重新实测。

## 现有能力

当前项目已经包含类型系统、约束、解析、校验/强制转换、AST diff、兼容性、注册表/DAG、补丁、代码生成、报告、CLI 和集成测试。适合在现有数据契约边界内扩展“可复现基准与审计”能力，而不是无关堆码。

## 初始文档/赛事问题

- README 和申报书多处写成“MoonBit 2026 开源创新大赛 / OSC 2026”，用户已明确实际赛事是 8 月黑客松。
- 文档把 0.10.3、4,023 行、49 组测试写死；当前本地工具链为 `moon 0.1.20260807`，需要用实际命令刷新指标。
- CI 当前已有三平台，但 `moon fmt --deny-warn` / `moon info --deny-warn` 与社区模板要求的 `moon fmt && git diff --exit-code`、`moon info && git diff --exit-code` 口径不同，且未显式覆盖 `--target all`、`moon update`、稳定后端构建/测试。

## 外部自查依据

- `Milky2018/osc2026-guide` 的 SKILL.md（公开原始文件）区分 OSC2026 与八月黑客松；黑客松验收明确要求 CI、Mooncakes 发布、README 可复现、核心路径测试、唯一贡献者和有效项目规模。
- `moonbit-community/.github/workflow-templates/check.yml`：三平台、稳定安装脚本、`moon version --all`、`moon update`、`moon check --target all`、`moon test --target all`、格式化与 `moon info` diff。
- `moonbit-community/.github/workflow-templates/publish.yml`：手工触发、先 check/test，再写入 token、`moon publish`，最后删除凭据。
- 参考仓库 `PaiGack/moonbit_sshclient` 的 workflow 增加了 `--deny-warn`、格式化、接口 diff、coverage 和 native 测试，可择取适合本项目的门禁。

## 待核验

- GitHub 当前授权账号和远程默认分支。
- Mooncakes 当前登录账号、包是否已发布及当前版本。
- 最新 stable MoonBit 的实际版本及本地升级后兼容性。
- 当前基线命令的真实输出和测试数量。

## 基线命令实测（2026-08-17）

- `moon version --all`：`moon 0.1.20260807`，`moonc v0.10.7+bc794d341`，`moonrun 0.1.20260807`。
- `moon check --deny-warn`：通过，运行 14 个任务。
- `moon test --deny-warn`：通过，`Total tests: 49, passed: 49, failed: 0`。
- `moon fmt --check`：通过。
- `moon info`：通过。
- 这组基线证明当前代码可编译且已有 49 个测试，但尚未证明 `--target all`、native 构建/测试、coverage、真实 benchmark 和 Mooncakes 发布状态。

## 结项阶段新增证据

- `moon check --deny-warn --target all` 通过。
- `moon test --deny-warn --target all` 的 wasm、wasm-gc、js 三目标均 59/59；Windows native 仅因本机 MinGW runtime 缺少 `rand_s` 失败，CI workflow 使用 MSYS2 UCRT64 处理。
- `scripts/verify_acceptance.ps1` 完整运行通过：production=4063、test=1064、total=5127、test_files=41。
- `scripts/benchmark.ps1 -Runs 5` 完整运行通过，当前报告记录 Windows、wasm-gc、520 operations/run 和 5 次 wall-clock 样本。
- `moon fmt` 和 `moon info` 已运行；`lib/pkg.generated.mbti` 等接口文件的新增公开 API diff 与审计/benchmark/Schema Profile 功能一致。
- 代码审查反馈已核实并处理：benchmark 文档改为 5 个样本且说明 Windows 使用 wasm-gc；CI native job 增加 native tests；Mooncakes workflow 限制为 `main` 并要求输入版本与 `moon.mod` 一致。
- 首次 CI 的 Ubuntu、macOS、native job 均通过；Windows 因下载 `msys2/setup-msys2` 被 GitHub codeload HTTP 429 限流。为消除该外部下载门禁，Windows 改为 wasm/wasm-gc/js 可移植目标，native 由 Ubuntu job 覆盖。
- 最终 CI run `32042535409` 已通过：Ubuntu、macOS、Windows portable targets、Ubuntu native build 全部成功；仅有 GitHub Actions Node.js 20 deprecation annotation。
- GitHub 仓库查询确认 owner=`lyjttio`、default branch=`main`；`moon whoami` 确认 Mooncakes=`lyjttio`；`moon publish` 返回 Server status `200 OK`，已发布 `lyjttio/moon-data-contract` `0.1.0`。

## 错误记录

- `gh auth status` 无法读取 GitHub CLI 配置，提示 Access is denied；最终推送前需要在授权环境直接核验。
- `gh api user` 曾多次返回 GitHub API HTTP 503，但 `gh repo view` 随后直接确认 owner=`lyjttio`、default branch=`main`；结合精确远程 dry-run/push 成功，GitHub 目标核验完成。
- 两个赛事 URL 被网页工具判定为不安全；已改用公开原始文件和搜索结果，未把未验证页面内容当作事实。
- `git add` / `git commit` 无法创建 `.git/index.lock`，提示 Permission denied；提交和推送阶段需要使用提升权限命令。

## 2026-08-18 扩展设计发现

- 当前生产规模为 4,063 行，新增 3,000–3,500 行即可进入 7,200–7,600 行目标区间。
- 现有根 `lib` 已依赖公开 `lib/types`，可复用 `@types.SemVer`、`Schema`、`DiffEntry`、`check_compatibility` 和 Registry，不需要新增第三方依赖。
- 由于 CLI 文件解析尚未实现，治理命令将采用确定性内置样例和库 API；文档必须明确这一边界。

## 2026-08-18 扩展结项证据

- 治理扩展已提交到本地 `189904c`：生产 `.mbt` 精确 7,200 行，测试源码 1,725 行，总量 8,925 行，测试文件 61 个。
- `moon test --deny-warn`：96/96；`moon check --deny-warn`、`moon fmt --check`、`moon info` 和 `moon check --deny-warn --target all` 通过。
- `moon test --deny-warn --target all` 的 wasm、wasm-gc、js 均 96/96；Windows 本机 native 仍因 MinGW runtime 缺少 `rand_s` 失败，CI 的 Ubuntu native job 保持覆盖。
- `scripts/verify_acceptance.ps1` 完整通过，输出 `production=7200 test=1725 total=8925 test_files=61`；`scripts/benchmark.ps1 -Runs 5` 通过，记录 792 operations/run、四个治理 workload 和 5 次 wall-clock 样本。
- `moon update` 提升权限后成功更新 registry index 与 symbols；`moon.mod` 已升级到 `0.2.0`，CLI version 输出同步为 `0.2.0`。
