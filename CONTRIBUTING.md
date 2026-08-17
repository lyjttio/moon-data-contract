# Contributing

本项目当前由 `lyjttio` 独立维护。提交改动前请在仓库根目录执行：

```powershell
moon fmt
moon info
moon check --deny-warn --target all
moon test --deny-warn --target all
```

新增或修改行为时，请为边界条件添加真实 MoonBit 测试，并确认 `pkg.generated.mbti` 的变化是预期的。不要提交 `_build`、`target`、`.mooncakes` 或本地凭据。
