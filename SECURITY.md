# Security policy

请不要在 issue、commit 或 benchmark 报告中提交 Mooncakes token、GitHub token、私有 Schema 或生产 Payload。安全问题请通过仓库维护者的私下渠道联系 `lyjttio`，并提供最小可复现信息。

发布 workflow 只从 GitHub Actions Secret `MOONCAKES_TOKEN` 读取凭据，发布步骤完成后立即删除临时 credentials 文件。
